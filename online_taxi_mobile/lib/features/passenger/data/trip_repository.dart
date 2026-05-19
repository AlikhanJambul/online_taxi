import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/grpc/grpc_client.dart';
import '../../../gen/trip.pb.dart' as pb;
import '../../../gen/trip.pbgrpc.dart';

enum TripStatus { searching, accepted, arrived, inProgress, completed, cancelled }

class TripEstimate {
  final int    priceKzt;
  final double distanceKm;
  const TripEstimate({required this.priceKzt, required this.distanceKm});
}

class Trip {
  final String     id;
  final String     passengerId;
  final String?    driverId;
  final TripStatus status;
  final String     pickupAddress;
  final String     destAddress;
  final double     pickupLat, pickupLng, destLat, destLng;
  final int        priceKzt;

  const Trip({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.status,
    required this.pickupAddress,
    required this.destAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destLat,
    required this.destLng,
    required this.priceKzt,
  });

  Trip copyWith({TripStatus? status}) => Trip(
    id: id, passengerId: passengerId, driverId: driverId,
    status: status ?? this.status,
    pickupAddress: pickupAddress, destAddress: destAddress,
    pickupLat: pickupLat, pickupLng: pickupLng,
    destLat: destLat, destLng: destLng,
    priceKzt: priceKzt,
  );
}

class TripRepository {
  final GrpcClients _grpc;
  TripRepository(this._grpc);

  TripServiceClient get _client =>
      TripServiceClient(_grpc.trip, interceptors: [_grpc.interceptor]);

  Future<TripEstimate> estimateTrip({
    required double pickupLat, required double pickupLng,
    required double destLat,   required double destLng,
  }) async {
    final res = await _client.estimateTrip(pb.EstimateRequest(
      pickupLat: pickupLat, pickupLng: pickupLng,
      destLat:   destLat,   destLng:   destLng,
    ));
    return TripEstimate(priceKzt: res.priceKzt, distanceKm: res.distanceKm);
  }

  Future<Trip> createTrip({
    required String pickupAddress, required String destAddress,
    required double pickupLat,     required double pickupLng,
    required double destLat,       required double destLng,
    required int    priceKzt,
  }) async {
    final res = await _client.createTrip(pb.CreateTripRequest(
      pickupAddress: pickupAddress, destAddress: destAddress,
      pickupLat:     pickupLat,     pickupLng:   pickupLng,
      destLat:       destLat,       destLng:     destLng,
      priceKzt:      Int64(priceKzt),
    ));
    return _mapTrip(res);
  }

  Future<void> cancelTrip(String tripId) async {
    await _client.cancelTrip(pb.TripIDRequest(tripId: tripId));
  }

  Future<Trip> getTrip(String tripId) async {
    final res = await _client.getTrip(pb.GetTripRequest(tripId: tripId));
    return _mapTrip(res);
  }

  // Server-streaming: сервер шлёт координаты водителя пока поездка активна
  Stream<({double lat, double lng})> trackDriverLocation(String tripId) {
    return _client
        .trackTrip(pb.TrackRequest(tripId: tripId))
        .map((r) => (lat: r.lat, lng: r.lng));
  }

  Trip _mapTrip(pb.TripResponse r) => Trip(
    id:            r.tripId,
    passengerId:   r.passengerId,
    driverId:      r.driverId.isEmpty ? null : r.driverId,
    status:        _mapStatus(r.status),
    pickupAddress: r.pickupAddress,
    destAddress:   r.destAddress,
    pickupLat:     r.pickupLat, pickupLng: r.pickupLng,
    destLat:       r.destLat,   destLng:   r.destLng,
    priceKzt:      r.priceKzt.toInt(),
  );

  TripStatus _mapStatus(pb.TripStatus s) {
    switch (s) {
      case pb.TripStatus.ACCEPTED:    return TripStatus.accepted;
      case pb.TripStatus.ARRIVED:     return TripStatus.arrived;
      case pb.TripStatus.IN_PROGRESS: return TripStatus.inProgress;
      case pb.TripStatus.COMPLETED:   return TripStatus.completed;
      case pb.TripStatus.CANCELLED:   return TripStatus.cancelled;
      default:                        return TripStatus.searching;
    }
  }
}

final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepository(ref.watch(grpcClientsProvider)),
);
