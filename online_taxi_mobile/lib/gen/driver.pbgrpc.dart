// This is a generated file - do not edit.
//
// Generated from driver.proto.

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

import 'driver.pb.dart' as $0;

export 'driver.pb.dart';

@$pb.GrpcServiceName('driver.DriverService')
class DriverServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DriverServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.DriverProfileResponse> createProfile(
    $0.CreateProfileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createProfile, request, options: options);
  }

  $grpc.ResponseFuture<$0.DriverProfileResponse> getProfile(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getProfile, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetUploadURLResponse> getCarUploadURL(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCarUploadURL, request, options: options);
  }

  $grpc.ResponseFuture<$0.DriverProfileResponse> getStats(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStats, request, options: options);
  }

  $grpc.ResponseFuture<$0.TripHistoryResponse> getTripHistory(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTripHistory, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> goOnline(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$goOnline, request, options: options);
  }

  // method descriptors

  static final _$createProfile =
      $grpc.ClientMethod<$0.CreateProfileRequest, $0.DriverProfileResponse>(
          '/driver.DriverService/CreateProfile',
          ($0.CreateProfileRequest value) => value.writeToBuffer(),
          $0.DriverProfileResponse.fromBuffer);
  static final _$getProfile =
      $grpc.ClientMethod<$1.Empty, $0.DriverProfileResponse>(
          '/driver.DriverService/GetProfile',
          ($1.Empty value) => value.writeToBuffer(),
          $0.DriverProfileResponse.fromBuffer);
  static final _$getCarUploadURL =
      $grpc.ClientMethod<$1.Empty, $0.GetUploadURLResponse>(
          '/driver.DriverService/GetCarUploadURL',
          ($1.Empty value) => value.writeToBuffer(),
          $0.GetUploadURLResponse.fromBuffer);
  static final _$getStats =
      $grpc.ClientMethod<$1.Empty, $0.DriverProfileResponse>(
          '/driver.DriverService/GetStats',
          ($1.Empty value) => value.writeToBuffer(),
          $0.DriverProfileResponse.fromBuffer);
  static final _$getTripHistory =
      $grpc.ClientMethod<$1.Empty, $0.TripHistoryResponse>(
          '/driver.DriverService/GetTripHistory',
          ($1.Empty value) => value.writeToBuffer(),
          $0.TripHistoryResponse.fromBuffer);
  static final _$goOnline = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/driver.DriverService/GoOnline',
      ($1.Empty value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
}

@$pb.GrpcServiceName('driver.DriverService')
abstract class DriverServiceBase extends $grpc.Service {
  $core.String get $name => 'driver.DriverService';

  DriverServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.CreateProfileRequest, $0.DriverProfileResponse>(
            'CreateProfile',
            createProfile_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateProfileRequest.fromBuffer(value),
            ($0.DriverProfileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.DriverProfileResponse>(
        'GetProfile',
        getProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.DriverProfileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.GetUploadURLResponse>(
        'GetCarUploadURL',
        getCarUploadURL_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.GetUploadURLResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.DriverProfileResponse> createProfile_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateProfileRequest> $request) async {
    return createProfile($call, await $request);
  }

  $async.Future<$0.DriverProfileResponse> createProfile(
      $grpc.ServiceCall call, $0.CreateProfileRequest request);

  $async.Future<$0.DriverProfileResponse> getProfile_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getProfile($call, await $request);
  }

  $async.Future<$0.DriverProfileResponse> getProfile(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.GetUploadURLResponse> getCarUploadURL_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getCarUploadURL($call, await $request);
  }

  $async.Future<$0.GetUploadURLResponse> getCarUploadURL(
      $grpc.ServiceCall call, $1.Empty request);
}
