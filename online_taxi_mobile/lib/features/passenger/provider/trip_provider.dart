import 'dart:async';
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
  }) => PassengerState(
    status:        status        ?? this.status,
    estimate:      estimate      ?? this.estimate,
    trip:          trip          ?? this.trip,
    error:         error,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    destAddress:   destAddress   ?? this.destAddress,
    pickupLat:     pickupLat     ?? this.pickupLat,
    pickupLng:     pickupLng     ?? this.pickupLng,
    destLat:       destLat       ?? this.destLat,
    destLng:       destLng       ?? this.destLng,
    driverLat:     driverLat     ?? this.driverLat,
    driverLng:     driverLng     ?? this.driverLng,
  );
}

class PassengerNotifier extends StateNotifier<PassengerState> {
  final TripRepository _repo;
  StreamSubscription? _trackSub;
  Timer?              _pollTimer;

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
    if (state.trip?.id != tripId) return;
    final newStatus = _parseStatusStr(statusStr);
    final updatedTrip = state.trip!.copyWith(status: newStatus);

    if (newStatus == TripStatus.completed || newStatus == TripStatus.cancelled) {
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

  void cancelSearch() {
    state = state.copyWith(status: PassengerFlowStatus.estimated, trip: null);
  }

  void reset() {
    _stopAll();
    state = const PassengerState();
  }

  void _startPolling(String tripId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final updated = await _repo.getTrip(tripId);
        if (updated.status == state.trip?.status) return;
        updateTripStatus(tripId, updated.status.name.toUpperCase());
      } catch (_) {}
    });
  }

  void _startDriverTracking(String tripId) {
    _trackSub?.cancel();
    _trackSub = _repo.trackDriverLocation(tripId).listen(
      (loc) => state = state.copyWith(driverLat: loc.lat, driverLng: loc.lng),
      onError: (_) {},
    );
  }

  void _stopAll() {
    _pollTimer?.cancel();
    _trackSub?.cancel();
    _pollTimer = null;
    _trackSub  = null;
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
