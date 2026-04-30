import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/driver_repository.dart';

export '../data/driver_repository.dart' show IncomingTrip;

enum DriverStatus { offline, online, hasTrip, inTrip }

class DriverState {
  final DriverStatus  status;
  final IncomingTrip? incomingTrip;
  final double?       lat, lng;
  final String?       error;

  const DriverState({
    this.status = DriverStatus.offline,
    this.incomingTrip,
    this.lat, this.lng,
    this.error,
  });

  DriverState copyWith({
    DriverStatus?  status,
    IncomingTrip?  incomingTrip,
    double?        lat, double? lng,
    String?        error,
  }) =>
      DriverState(
        status:       status       ?? this.status,
        incomingTrip: incomingTrip ?? this.incomingTrip,
        lat:          lat          ?? this.lat,
        lng:          lng          ?? this.lng,
        error:        error,
      );

  DriverState clearTrip() =>
      DriverState(status: DriverStatus.online, lat: lat, lng: lng);
}

class DriverNotifier extends StateNotifier<DriverState> {
  final DriverRepository _repo;
  StreamSubscription<Position>? _locationSub;
  Timer? _mockTripTimer;

  DriverNotifier(this._repo) : super(const DriverState());

  Future<void> goOnline() async {
    state = state.copyWith(status: DriverStatus.online);
    _startLocationTracking();
    // Мок: через 5 сек приходит заказ (в реале — FCM пуш)
    _mockTripTimer = Timer(const Duration(seconds: 5), _mockIncomingTrip);
  }

  void goOffline() {
    _locationSub?.cancel();
    _mockTripTimer?.cancel();
    state = const DriverState(status: DriverStatus.offline);
  }

  void _mockIncomingTrip() {
    if (state.status != DriverStatus.online) return;
    state = state.copyWith(
      status: DriverStatus.hasTrip,
      incomingTrip: const IncomingTrip(
        id: 'mock_trip_id',
        pickupAddress: 'Байконурова 12',
        destAddress:   'Достык пл. 3',
        pickupLat: 51.18, pickupLng: 71.44,
        priceKzt: 1200, distanceKm: 4.3,
      ),
    );
  }

  Future<void> acceptTrip(String tripId) async {
    try {
      await _repo.acceptTrip(tripId);
      state = state.copyWith(status: DriverStatus.inTrip);
    } catch (e) {
      state = state.copyWith(error: 'Не удалось принять заказ');
    }
  }

  void declineTrip() {
    state = state.clearTrip();
    _mockTripTimer = Timer(const Duration(seconds: 8), _mockIncomingTrip);
  }

  void completeTrip() => state = state.clearTrip();

  void _startLocationTracking() {
    _locationSub?.cancel();
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      state = state.copyWith(lat: pos.latitude, lng: pos.longitude);
      // TODO: отправлять через gRPC SendLocation стрим
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _mockTripTimer?.cancel();
    super.dispose();
  }
}

final driverProvider = StateNotifierProvider<DriverNotifier, DriverState>(
  (ref) => DriverNotifier(ref.watch(driverRepositoryProvider)),
);
