import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import '../../../core/grpc/grpc_client.dart';
import '../../../gen/trip.pb.dart' as pb;
import '../../../gen/trip.pbgrpc.dart';
import '../../../gen/driver.pb.dart' as dpb;
import '../../../gen/driver.pbgrpc.dart';

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

  StreamController<pb.LocationRequest>? _locationCtrl;

  TripServiceClient get _client =>
      TripServiceClient(_grpc.trip, interceptors: [_grpc.interceptor]);

  DriverServiceClient get _driverClient =>
      DriverServiceClient(_grpc.driver, interceptors: [_grpc.interceptor]);

  Future<dpb.DriverProfileResponse> getProfile() async {
    return await _driverClient.getProfile(Empty());
  }

  Future<String> getCarUploadUrl() async {
    final res = await _driverClient.getCarUploadURL(Empty());
    return res.uploadUrl;
  }

  Future<void> createProfile({
    required String carMake,
    required String carModel,
    required String carColor,
    required String licensePlate,
  }) async {
    await _driverClient.createProfile(dpb.CreateProfileRequest(
      carMake:      carMake,
      carModel:     carModel,
      carColor:     carColor,
      licensePlate: licensePlate,
    ));
  }

  Future<void> acceptTrip(String tripId) async {
    await _client.acceptTrip(pb.AcceptTripRequest(tripId: tripId));
  }

  Future<void> driverArrived(String tripId) async {
    await _client.driverArrived(pb.TripIDRequest(tripId: tripId));
  }

  Future<void> startTrip(String tripId) async {
    await _client.startTrip(pb.TripIDRequest(tripId: tripId));
  }

  Future<void> completeTrip(String tripId) async {
    await _client.completeTrip(pb.TripIDRequest(tripId: tripId));
  }

  Future<void> cancelTrip(String tripId) async {
    await _client.cancelTrip(pb.TripIDRequest(tripId: tripId));
  }

  // Открывает gRPC client-streaming канал для отправки координат
  void startLocationStream() {
    if (_locationCtrl != null && !_locationCtrl!.isClosed) return;
    _locationCtrl = StreamController<pb.LocationRequest>();
    _client.sendLocation(_locationCtrl!.stream);
  }

  // Отправляет одну точку. tripId пустой если водитель просто на линии.
  void sendLocation(double lat, double lng, {String tripId = ''}) {
    if (_locationCtrl == null || _locationCtrl!.isClosed) return;
    _locationCtrl!.add(pb.LocationRequest(
      tripId: tripId,
      lat:    lat,
      lng:    lng,
    ));
  }

  Future<void> stopLocationStream() async {
    await _locationCtrl?.close();
    _locationCtrl = null;
  }
}

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DriverRepository(ref.watch(grpcClientsProvider)),
);
