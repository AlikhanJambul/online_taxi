import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/driver_repository.dart';

export '../data/driver_repository.dart' show IncomingTrip;

enum DriverStatus { offline, online, hasTrip, arrived, inTrip }

class DriverState {
  final DriverStatus  status;
  final IncomingTrip? incomingTrip;
  final String?       activeTripId;
  final double?       lat, lng;
  final String?       error;

  const DriverState({
    this.status = DriverStatus.offline,
    this.incomingTrip,
    this.activeTripId,
    this.lat, this.lng,
    this.error,
  });

  DriverState copyWith({
    DriverStatus?  status,
    IncomingTrip?  incomingTrip,
    String?        activeTripId,
    double?        lat, double? lng,
    String?        error,
    bool           clearTrip = false,
  }) =>
      DriverState(
        status:       status       ?? this.status,
        incomingTrip: clearTrip ? null : (incomingTrip ?? this.incomingTrip),
        activeTripId: activeTripId ?? this.activeTripId,
        lat:          lat          ?? this.lat,
        lng:          lng          ?? this.lng,
        error:        error,
      );
}

class DriverNotifier extends StateNotifier<DriverState> {
  final DriverRepository _repo;
  StreamSubscription<Position>? _locationSub;

  DriverNotifier(this._repo) : super(const DriverState());

  Future<void> goOnline() async {
    state = state.copyWith(status: DriverStatus.online);
    _repo.startLocationStream();
    _startGpsTracking();
  }

  Future<void> goOffline() async {
    _locationSub?.cancel();
    await _repo.stopLocationStream();
    state = const DriverState(status: DriverStatus.offline);
  }

  // Вызывается из FCM-обработчика когда приходит пуш о новом заказе
  void notifyIncomingTrip(IncomingTrip trip) {
    if (state.status != DriverStatus.online) return;
    state = state.copyWith(status: DriverStatus.hasTrip, incomingTrip: trip);
  }

  Future<void> acceptTrip(String tripId) async {
    try {
      await _repo.acceptTrip(tripId);
      state = state.copyWith(
        status:      DriverStatus.inTrip,
        activeTripId: tripId,
        clearTrip:   true,
      );
    } catch (e) {
      state = state.copyWith(error: 'Не удалось принять заказ');
    }
  }

  void declineTrip() {
    state = state.copyWith(status: DriverStatus.online, clearTrip: true);
  }

  Future<void> markArrived() async {
    final tripId = state.activeTripId;
    if (tripId == null) return;
    try {
      await _repo.driverArrived(tripId);
      state = state.copyWith(status: DriverStatus.arrived);
    } catch (e) {
      state = state.copyWith(error: 'Ошибка обновления статуса');
    }
  }

  Future<void> startDriving() async {
    final tripId = state.activeTripId;
    if (tripId == null) return;
    try {
      await _repo.startTrip(tripId);
      state = state.copyWith(status: DriverStatus.inTrip);
    } catch (e) {
      state = state.copyWith(error: 'Ошибка обновления статуса');
    }
  }

  Future<void> completeTrip() async {
    final tripId = state.activeTripId;
    if (tripId == null) return;
    try {
      await _repo.completeTrip(tripId);
      state = state.copyWith(
        status:      DriverStatus.online,
        activeTripId: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Не удалось завершить поездку');
    }
  }

  Future<void> cancelCurrentTrip() async {
    final tripId = state.activeTripId;
    if (tripId == null) return;
    try {
      await _repo.cancelTrip(tripId);
      state = state.copyWith(
        status:      DriverStatus.online,
        activeTripId: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Не удалось отменить поездку');
    }
  }

  void _startGpsTracking() {
    _locationSub?.cancel();
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy:       LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      state = state.copyWith(lat: pos.latitude, lng: pos.longitude);
      _repo.sendLocation(
        pos.latitude,
        pos.longitude,
        tripId: state.activeTripId ?? '',
      );
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _repo.stopLocationStream();
    super.dispose();
  }
}

final driverProvider = StateNotifierProvider<DriverNotifier, DriverState>(
  (ref) => DriverNotifier(ref.watch(driverRepositoryProvider)),
);
