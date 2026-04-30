import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/grpc/grpc_client.dart';

// TODO: import '../../../gen/trip.pbgrpc.dart';

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
}

class TripRepository {
  final GrpcClients _grpc;
  TripRepository(this._grpc);

  Future<TripEstimate> estimateTrip({
    required double pickupLat, required double pickupLng,
    required double destLat,   required double destLng,
  }) async {
    // TODO: раскомментируй после генерации proto
    // final client = TripServiceClient(_grpc.trip, interceptors: [_grpc.interceptor]);
    // final res = await client.estimateTrip(EstimateRequest(
    //   pickupLat: pickupLat, pickupLng: pickupLng,
    //   destLat: destLat,     destLng: destLng,
    // ));
    // return TripEstimate(priceKzt: res.priceKzt, distanceKm: res.distanceKm);

    await Future.delayed(const Duration(milliseconds: 600));
    final dist = _haversine(pickupLat, pickupLng, destLat, destLng);
    return TripEstimate(priceKzt: (500 + dist * 150).toInt(), distanceKm: dist);
  }

  Future<Trip> createTrip({
    required String pickupAddress, required String destAddress,
    required double pickupLat,     required double pickupLng,
    required double destLat,       required double destLng,
  }) async {
    // TODO: раскомментируй после генерации proto
    // final client = TripServiceClient(_grpc.trip, interceptors: [_grpc.interceptor]);
    // final res = await client.createTrip(CreateTripRequest(
    //   pickupAddress: pickupAddress, destAddress: destAddress,
    //   pickupLat: pickupLat,         pickupLng: pickupLng,
    //   destLat: destLat,             destLng: destLng,
    // ));
    // return _mapTrip(res);

    await Future.delayed(const Duration(milliseconds: 800));
    final dist = _haversine(pickupLat, pickupLng, destLat, destLng);
    return Trip(
      id: 'mock_trip_id',
      passengerId: 'mock_user_id',
      status: TripStatus.searching,
      pickupAddress: pickupAddress,
      destAddress: destAddress,
      pickupLat: pickupLat, pickupLng: pickupLng,
      destLat: destLat,     destLng: destLng,
      priceKzt: (500 + dist * 150).toInt(),
    );
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = pow(sin(dLat / 2), 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * pow(sin(dLng / 2), 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}

final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepository(ref.watch(grpcClientsProvider)),
);
