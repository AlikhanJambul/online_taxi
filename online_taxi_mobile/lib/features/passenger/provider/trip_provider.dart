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

  const PassengerState({
    this.status = PassengerFlowStatus.idle,
    this.estimate,
    this.trip,
    this.error,
    this.pickupAddress = '',
    this.destAddress   = '',
    this.pickupLat, this.pickupLng,
    this.destLat,   this.destLng,
  });

  PassengerState copyWith({
    PassengerFlowStatus? status,
    TripEstimate? estimate,
    Trip? trip,
    String? error,
    String? pickupAddress,
    String? destAddress,
    double? pickupLat, double? pickupLng,
    double? destLat,   double? destLng,
  }) =>
      PassengerState(
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
      );
}

class PassengerNotifier extends StateNotifier<PassengerState> {
  final TripRepository _repo;
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
      );
      state = state.copyWith(status: PassengerFlowStatus.searching, trip: trip);
    } catch (e) {
      state = state.copyWith(status: PassengerFlowStatus.error, error: e.toString());
    }
  }

  void cancelSearch() => state = state.copyWith(status: PassengerFlowStatus.estimated, trip: null);

  void reset() => state = const PassengerState();
}

final passengerProvider = StateNotifierProvider<PassengerNotifier, PassengerState>(
  (ref) => PassengerNotifier(ref.watch(tripRepositoryProvider)),
);
