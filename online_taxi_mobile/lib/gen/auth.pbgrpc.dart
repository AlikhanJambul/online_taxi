// This is a generated file - do not edit.
//
// Generated from auth.proto.

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

import 'auth.pb.dart' as $0;

export 'auth.pb.dart';

@$pb.GrpcServiceName('auth.AuthService')
class AuthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuthServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.AuthResponse> register(
    $0.RegisterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseFuture<$0.AuthResponse> login(
    $0.LoginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$login, request, options: options);
  }

  $grpc.ResponseFuture<$0.RefreshResponse> refresh(
    $0.RefreshRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refresh, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> logout(
    $0.LogoutRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$logout, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> updateFCMToken(
    $0.UpdateFCMRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateFCMToken, request, options: options);
  }

  // method descriptors

  static final _$register =
      $grpc.ClientMethod<$0.RegisterRequest, $0.AuthResponse>(
          '/auth.AuthService/Register',
          ($0.RegisterRequest value) => value.writeToBuffer(),
          $0.AuthResponse.fromBuffer);
  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.AuthResponse>(
      '/auth.AuthService/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      $0.AuthResponse.fromBuffer);
  static final _$refresh =
      $grpc.ClientMethod<$0.RefreshRequest, $0.RefreshResponse>(
          '/auth.AuthService/Refresh',
          ($0.RefreshRequest value) => value.writeToBuffer(),
          $0.RefreshResponse.fromBuffer);
  static final _$logout = $grpc.ClientMethod<$0.LogoutRequest, $1.Empty>(
      '/auth.AuthService/Logout',
      ($0.LogoutRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$updateFCMToken =
      $grpc.ClientMethod<$0.UpdateFCMRequest, $1.Empty>(
          '/auth.AuthService/UpdateFCMToken',
          ($0.UpdateFCMRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
}

@$pb.GrpcServiceName('auth.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'auth.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RegisterRequest, $0.AuthResponse>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RegisterRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.AuthResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RefreshRequest, $0.RefreshResponse>(
        'Refresh',
        refresh_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RefreshRequest.fromBuffer(value),
        ($0.RefreshResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogoutRequest, $1.Empty>(
        'Logout',
        logout_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogoutRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateFCMRequest, $1.Empty>(
        'UpdateFCMToken',
        updateFCMToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateFCMRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthResponse> register_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterRequest> $request) async {
    return register($call, await $request);
  }

  $async.Future<$0.AuthResponse> register(
      $grpc.ServiceCall call, $0.RegisterRequest request);

  $async.Future<$0.AuthResponse> login_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoginRequest> $request) async {
    return login($call, await $request);
  }

  $async.Future<$0.AuthResponse> login(
      $grpc.ServiceCall call, $0.LoginRequest request);

  $async.Future<$0.RefreshResponse> refresh_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RefreshRequest> $request) async {
    return refresh($call, await $request);
  }

  $async.Future<$0.RefreshResponse> refresh(
      $grpc.ServiceCall call, $0.RefreshRequest request);

  $async.Future<$1.Empty> logout_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LogoutRequest> $request) async {
    return logout($call, await $request);
  }

  $async.Future<$1.Empty> logout(
      $grpc.ServiceCall call, $0.LogoutRequest request);

  $async.Future<$1.Empty> updateFCMToken_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateFCMRequest> $request) async {
    return updateFCMToken($call, await $request);
  }

  $async.Future<$1.Empty> updateFCMToken(
      $grpc.ServiceCall call, $0.UpdateFCMRequest request);
}
