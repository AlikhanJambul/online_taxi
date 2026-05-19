// This is a generated file - do not edit.
//
// Generated from trip.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'trip.pb.dart' as $0;

export 'trip.pb.dart';

@$pb.GrpcServiceName('trip.TripService')
class TripServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TripServiceClient(super.channel, {super.options, super.interceptors});

  /// 1. Пассажир создает заявку (ищет машину)
  $grpc.ResponseFuture<$0.TripResponse> createTrip(
    $0.CreateTripRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createTrip, request, options: options);
  }

  /// 2. Водитель принимает заказ
  $grpc.ResponseFuture<$0.TripResponse> acceptTrip(
    $0.AcceptTripRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$acceptTrip, request, options: options);
  }

  /// 3. Получить инфу по конкретной поездке
  $grpc.ResponseFuture<$0.TripResponse> getTrip(
    $0.GetTripRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTrip, request, options: options);
  }

  /// 4. Узнать стоимость поездки
  $grpc.ResponseFuture<$0.EstimateResponse> estimateTrip(
    $0.EstimateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$estimateTrip, request, options: options);
  }

  /// 5. Водитель постоянно шлет свои координаты (Client Streaming)
  /// Ключевое слово stream в запросе значит, что клиент открывает трубу и пуляет данные
  $grpc.ResponseFuture<$1.Empty> sendLocation(
    $async.Stream<$0.LocationRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$sendLocation, request, options: options)
        .single;
  }

  /// 6. Пассажир слушает перемещения водителя (Server Streaming)
  /// Ключевое слово stream в ответе значит, что сервер постоянно отдает данные клиенту
  $grpc.ResponseStream<$0.LocationResponse> trackTrip(
    $0.TrackRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$trackTrip, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// 7. Водитель прибыл на место
  $grpc.ResponseFuture<$0.TripResponse> driverArrived(
    $0.TripIDRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$driverArrived, request, options: options);
  }

  /// 8. Водитель начал поездку
  $grpc.ResponseFuture<$0.TripResponse> startTrip(
    $0.TripIDRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$startTrip, request, options: options);
  }

  /// 9. Водитель завершил поездку
  $grpc.ResponseFuture<$0.TripResponse> completeTrip(
    $0.TripIDRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$completeTrip, request, options: options);
  }

  /// 10. Отмена поездки (и пассажир и водитель могут отменить)
  $grpc.ResponseFuture<$0.TripResponse> cancelTrip(
    $0.TripIDRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cancelTrip, request, options: options);
  }

  // method descriptors

  static final _$createTrip =
      $grpc.ClientMethod<$0.CreateTripRequest, $0.TripResponse>(
          '/trip.TripService/CreateTrip',
          ($0.CreateTripRequest value) => value.writeToBuffer(),
          $0.TripResponse.fromBuffer);
  static final _$acceptTrip =
      $grpc.ClientMethod<$0.AcceptTripRequest, $0.TripResponse>(
          '/trip.TripService/AcceptTrip',
          ($0.AcceptTripRequest value) => value.writeToBuffer(),
          $0.TripResponse.fromBuffer);
  static final _$getTrip =
      $grpc.ClientMethod<$0.GetTripRequest, $0.TripResponse>(
          '/trip.TripService/GetTrip',
          ($0.GetTripRequest value) => value.writeToBuffer(),
          $0.TripResponse.fromBuffer);
  static final _$estimateTrip =
      $grpc.ClientMethod<$0.EstimateRequest, $0.EstimateResponse>(
          '/trip.TripService/EstimateTrip',
          ($0.EstimateRequest value) => value.writeToBuffer(),
          $0.EstimateResponse.fromBuffer);
  static final _$sendLocation =
      $grpc.ClientMethod<$0.LocationRequest, $1.Empty>(
          '/trip.TripService/SendLocation',
          ($0.LocationRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$trackTrip =
      $grpc.ClientMethod<$0.TrackRequest, $0.LocationResponse>(
          '/trip.TripService/TrackTrip',
          ($0.TrackRequest value) => value.writeToBuffer(),
          $0.LocationResponse.fromBuffer);
  static final _$driverArrived =
      $grpc.ClientMethod<$0.TripIDRequest, $0.TripResponse>(
          '/trip.TripService/DriverArrived',
          ($0.TripIDRequest value) => value.writeToBuffer(),
          $0.TripResponse.fromBuffer);
  static final _$startTrip =
      $grpc.ClientMethod<$0.TripIDRequest, $0.TripResponse>(
          '/trip.TripService/StartTrip',
          ($0.TripIDRequest value) => value.writeToBuffer(),
          $0.TripResponse.fromBuffer);
  static final _$completeTrip =
      $grpc.ClientMethod<$0.TripIDRequest, $0.TripResponse>(
          '/trip.TripService/CompleteTrip',
          ($0.TripIDRequest value) => value.writeToBuffer(),
          $0.TripResponse.fromBuffer);
  static final _$cancelTrip =
      $grpc.ClientMethod<$0.TripIDRequest, $0.TripResponse>(
          '/trip.TripService/CancelTrip',
          ($0.TripIDRequest value) => value.writeToBuffer(),
          $0.TripResponse.fromBuffer);
}

@$pb.GrpcServiceName('trip.TripService')
abstract class TripServiceBase extends $grpc.Service {
  $core.String get $name => 'trip.TripService';

  TripServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateTripRequest, $0.TripResponse>(
        'CreateTrip',
        createTrip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateTripRequest.fromBuffer(value),
        ($0.TripResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AcceptTripRequest, $0.TripResponse>(
        'AcceptTrip',
        acceptTrip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AcceptTripRequest.fromBuffer(value),
        ($0.TripResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetTripRequest, $0.TripResponse>(
        'GetTrip',
        getTrip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetTripRequest.fromBuffer(value),
        ($0.TripResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EstimateRequest, $0.EstimateResponse>(
        'EstimateTrip',
        estimateTrip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EstimateRequest.fromBuffer(value),
        ($0.EstimateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LocationRequest, $1.Empty>(
        'SendLocation',
        sendLocation,
        true,
        false,
        ($core.List<$core.int> value) => $0.LocationRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TrackRequest, $0.LocationResponse>(
        'TrackTrip',
        trackTrip_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.TrackRequest.fromBuffer(value),
        ($0.LocationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TripIDRequest, $0.TripResponse>(
        'DriverArrived',
        driverArrived_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TripIDRequest.fromBuffer(value),
        ($0.TripResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TripIDRequest, $0.TripResponse>(
        'StartTrip',
        startTrip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TripIDRequest.fromBuffer(value),
        ($0.TripResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TripIDRequest, $0.TripResponse>(
        'CompleteTrip',
        completeTrip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TripIDRequest.fromBuffer(value),
        ($0.TripResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TripIDRequest, $0.TripResponse>(
        'CancelTrip',
        cancelTrip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TripIDRequest.fromBuffer(value),
        ($0.TripResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.TripResponse> createTrip_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateTripRequest> $request) async {
    return createTrip($call, await $request);
  }

  $async.Future<$0.TripResponse> createTrip(
      $grpc.ServiceCall call, $0.CreateTripRequest request);

  $async.Future<$0.TripResponse> acceptTrip_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AcceptTripRequest> $request) async {
    return acceptTrip($call, await $request);
  }

  $async.Future<$0.TripResponse> acceptTrip(
      $grpc.ServiceCall call, $0.AcceptTripRequest request);

  $async.Future<$0.TripResponse> getTrip_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetTripRequest> $request) async {
    return getTrip($call, await $request);
  }

  $async.Future<$0.TripResponse> getTrip(
      $grpc.ServiceCall call, $0.GetTripRequest request);

  $async.Future<$0.EstimateResponse> estimateTrip_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EstimateRequest> $request) async {
    return estimateTrip($call, await $request);
  }

  $async.Future<$0.EstimateResponse> estimateTrip(
      $grpc.ServiceCall call, $0.EstimateRequest request);

  $async.Future<$1.Empty> sendLocation(
      $grpc.ServiceCall call, $async.Stream<$0.LocationRequest> request);

  $async.Stream<$0.LocationResponse> trackTrip_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.TrackRequest> $request) async* {
    yield* trackTrip($call, await $request);
  }

  $async.Stream<$0.LocationResponse> trackTrip(
      $grpc.ServiceCall call, $0.TrackRequest request);

  $async.Future<$0.TripResponse> driverArrived_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.TripIDRequest> $request) async {
    return driverArrived($call, await $request);
  }

  $async.Future<$0.TripResponse> driverArrived(
      $grpc.ServiceCall call, $0.TripIDRequest request);

  $async.Future<$0.TripResponse> startTrip_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.TripIDRequest> $request) async {
    return startTrip($call, await $request);
  }

  $async.Future<$0.TripResponse> startTrip(
      $grpc.ServiceCall call, $0.TripIDRequest request);

  $async.Future<$0.TripResponse> completeTrip_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.TripIDRequest> $request) async {
    return completeTrip($call, await $request);
  }

  $async.Future<$0.TripResponse> completeTrip(
      $grpc.ServiceCall call, $0.TripIDRequest request);

  $async.Future<$0.TripResponse> cancelTrip_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.TripIDRequest> $request) async {
    return cancelTrip($call, await $request);
  }

  $async.Future<$0.TripResponse> cancelTrip(
      $grpc.ServiceCall call, $0.TripIDRequest request);
}
