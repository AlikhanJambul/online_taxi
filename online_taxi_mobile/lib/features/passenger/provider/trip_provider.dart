import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/trip_repository.dart';

export '../data/trip_repository.dart' show TripStatus, TripEstimate, Trip;

enum PassengerFlowStatus { idle, estimating, estimated, creating, searching, active, error }

class PassengerState {
  final PassengerFlowStatus status;
  final TripEstimate?        estimate;
  final Trip?                trip;
  final String?              error;
  final String               pickupAddress;
  final String               destAddress;
  final double?              pickupLat, pickupLng, destLat, destLng;
  final double?              driverLat, driverLng;
  final bool                 pendingReview;
  final String?              completedTripId;

  const PassengerState({
    this.status = PassengerFlowStatus.idle,
    this.estimate,
    this.trip,
    this.error,
    this.pickupAddress = '',
    this.destAddress   = '',
    this.pickupLat, this.pickupLng,
    this.destLat,   this.destLng,
    this.driverLat, this.driverLng,
    this.pendingReview  = false,
    this.completedTripId,
  });

  PassengerState copyWith({
    PassengerFlowStatus? status,
    TripEstimate? estimate,
    Trip?         trip,
    String?       error,
    String?       pickupAddress,
    String?       destAddress,
    double? pickupLat, double? pickupLng,
    double? destLat,   double? destLng,
    double? driverLat, double? driverLng,
    bool?   pendingReview,
    String? completedTripId,
  }) => PassengerState(
    status:          status          ?? this.status,
    estimate:        estimate        ?? this.estimate,
    trip:            trip            ?? this.trip,
    error:           error,                            // намеренно transient: null сбрасывает
    pickupAddress:   pickupAddress   ?? this.pickupAddress,
    destAddress:     destAddress     ?? this.destAddress,
    pickupLat:       pickupLat       ?? this.pickupLat,
    pickupLng:       pickupLng       ?? this.pickupLng,
    destLat:         destLat         ?? this.destLat,
    destLng:         destLng         ?? this.destLng,
    driverLat:       driverLat       ?? this.driverLat,
    driverLng:       driverLng       ?? this.driverLng,
    pendingReview:   pendingReview   ?? this.pendingReview,
    completedTripId: completedTripId ?? this.completedTripId,
  );
}

class PassengerNotifier extends StateNotifier<PassengerState> {
  final TripRepository _repo;
  StreamSubscription? _trackSub;
  Timer?              _pollTimer;
  Timer?              _searchTimeoutTimer;
  // Защита от повторного показа диалога отзыва при дублирующих FCM/poll
  final _finishedTrips = <String>{};

  PassengerNotifier(this._repo) : super(const PassengerState());

  void setPickup({required String address, required double lat, required double lng}) {
    state = state.copyWith(pickupAddress: address, pickupLat: lat, pickupLng: lng);
    _tryEstimate();
  }

  void setDest({required String address, required double lat, required double lng}) {
    state = state.copyWith(destAddress: address, destLat: lat, destLng: lng);
    _tryEstimate();
  }

  Future<void> _tryEstimate() async {
    if (state.pickupLat == null || state.destLat == null) return;
    state = state.copyWith(status: PassengerFlowStatus.estimating);
    try {
      final est = await _repo.estimateTrip(
        pickupLat: state.pickupLat!, pickupLng: state.pickupLng!,
        destLat:   state.destLat!,   destLng:   state.destLng!,
      );
      state = state.copyWith(status: PassengerFlowStatus.estimated, estimate: est);
    } catch (e) {
      state = state.copyWith(status: PassengerFlowStatus.error, error: e.toString());
    }
  }

  Future<void> createTrip() async {
    if (state.pickupLat == null || state.destLat == null) return;
    state = state.copyWith(status: PassengerFlowStatus.creating);
    try {
      final trip = await _repo.createTrip(
        pickupAddress: state.pickupAddress,
        destAddress:   state.destAddress,
        pickupLat: state.pickupLat!, pickupLng: state.pickupLng!,
        destLat:   state.destLat!,   destLng:   state.destLng!,
        priceKzt:  state.estimate?.priceKzt ?? 0,
      );
      state = state.copyWith(status: PassengerFlowStatus.searching, trip: trip);
      _startPolling(trip.id);
    } catch (e) {
      state = state.copyWith(status: PassengerFlowStatus.error, error: e.toString());
    }
  }

  // Вызывается из FCM-обработчика когда меняется статус поездки
  void updateTripStatus(String tripId, String statusStr) {
    if (_finishedTrips.contains(tripId)) return;
    if (state.trip?.id != tripId) return;
    final newStatus = _parseStatusStr(statusStr);
    final updatedTrip = state.trip!.copyWith(status: newStatus);

    if (newStatus == TripStatus.completed) {
      _finishedTrips.add(tripId);
      _stopAll();
      state = PassengerState(
        pendingReview:   true,
        completedTripId: tripId,
      );
      return;
    }
    if (newStatus == TripStatus.cancelled) {
      _stopAll();
      state = const PassengerState();
      return;
    }

    state = state.copyWith(
      status: PassengerFlowStatus.active,
      trip:   updatedTrip,
    );

    if (newStatus == TripStatus.accepted ||
        newStatus == TripStatus.arrived  ||
        newStatus == TripStatus.inProgress) {
      _startDriverTracking(tripId);
    }
  }

  Future<void> cancelTrip() async {
    final tripId = state.trip?.id;
    if (tripId == null) return;
    _stopAll();
    try {
      await _repo.cancelTrip(tripId);
    } catch (_) {}
    state = const PassengerState();
  }

  /// Отмена во время поиска водителя — обновляет UI немедленно,
  /// отменяет поездку на сервере в фоне.
  Future<void> cancelSearch() async {
    final tripId = state.trip?.id;
    _stopAll();
    state = state.copyWith(status: PassengerFlowStatus.estimated, trip: null);
    if (tripId != null) {
      try { await _repo.cancelTrip(tripId); } catch (_) {}
    }
  }

  void reset() {
    _stopAll();
    state = const PassengerState();
  }

  Future<void> submitReview(int score) async {
    final tripId = state.completedTripId;
    if (tripId != null) {
      try {
        await _repo.submitReview(tripId: tripId, score: score);
      } catch (_) {} // отзыв не критичен
    }
    state = const PassengerState();
  }

  void dismissReview() {
    state = const PassengerState();
  }

  void _startPolling(String tripId) {
    _pollTimer?.cancel();
    _searchTimeoutTimer?.cancel();

    // Таймаут поиска: 2 минуты — если водитель не нашёлся, отменяем и сообщаем
    _searchTimeoutTimer = Timer(const Duration(minutes: 2), () async {
      if (state.status != PassengerFlowStatus.searching) return;
      _stopAll();
      try { await _repo.cancelTrip(tripId); } catch (_) {}
      state = const PassengerState(
        status: PassengerFlowStatus.error,
        error: 'Водителей рядом нет. Попробуйте позже.',
      );
    });

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final updated = await _repo.getTrip(tripId);

        // Подгружаем данные машины — только если поездка ещё активна
        final cur = state.trip;
        if (updated.carMake.isNotEmpty &&
            cur != null &&
            cur.carMake.isEmpty &&
            state.trip?.id == tripId) {
          state = state.copyWith(
            trip: cur.copyWith(
              carMake:         updated.carMake,
              carModel:        updated.carModel,
              carColor:        updated.carColor,
              licensePlate:    updated.licensePlate,
              driverAvatarUrl: updated.driverAvatarUrl,
            ),
          );
        }

        if (updated.status == state.trip?.status) return;
        updateTripStatus(tripId, updated.status.name.toUpperCase());
      } catch (_) {}
    });
  }

  void _startDriverTracking(String tripId) {
    if (_trackSub != null) return; // уже слушаем
    debugPrint('[TrackTrip] подписка на координаты водителя, tripId=$tripId');
    _trackSub = _repo.trackDriverLocation(tripId).listen(
      (loc) {
        debugPrint('[TrackTrip] координаты водителя: ${loc.lat}, ${loc.lng}');
        state = state.copyWith(driverLat: loc.lat, driverLng: loc.lng);
      },
      onError: (e) => debugPrint('[TrackTrip] ошибка стрима: $e'),
      onDone: () => debugPrint('[TrackTrip] стрим завершён'),
    );
  }

  void _stopAll() {
    _pollTimer?.cancel();
    _trackSub?.cancel();
    _searchTimeoutTimer?.cancel();
    _pollTimer            = null;
    _trackSub             = null;
    _searchTimeoutTimer   = null;
  }

  TripStatus _parseStatusStr(String s) {
    switch (s.toUpperCase()) {
      case 'ACCEPTED':    return TripStatus.accepted;
      case 'ARRIVED':     return TripStatus.arrived;
      case 'IN_PROGRESS': return TripStatus.inProgress;
      case 'COMPLETED':   return TripStatus.completed;
      case 'CANCELLED':   return TripStatus.cancelled;
      default:            return TripStatus.searching;
    }
  }

  @override
  void dispose() {
    _stopAll();
    super.dispose();
  }
}

final passengerProvider = StateNotifierProvider<PassengerNotifier, PassengerState>(
  (ref) => PassengerNotifier(ref.watch(tripRepositoryProvider)),
);
