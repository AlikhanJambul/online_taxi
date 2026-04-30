import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/grpc/grpc_client.dart';

// TODO: import '../../../gen/trip.pbgrpc.dart';

class IncomingTrip {
  final String id;
  final String pickupAddress;
  final String destAddress;
  final double pickupLat, pickupLng;
  final int    priceKzt;
  final double distanceKm;

  const IncomingTrip({
    required this.id,
    required this.pickupAddress,
    required this.destAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.priceKzt,
    required this.distanceKm,
  });
}

class DriverRepository {
  final GrpcClients _grpc;
  DriverRepository(this._grpc);

  Future<void> acceptTrip(String tripId) async {
    // TODO: раскомментируй после генерации proto
    // final client = TripServiceClient(_grpc.trip, interceptors: [_grpc.interceptor]);
    // await client.acceptTrip(AcceptTripRequest(tripId: tripId));
    await Future.delayed(const Duration(milliseconds: 600));
  }
}

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DriverRepository(ref.watch(grpcClientsProvider)),
);
