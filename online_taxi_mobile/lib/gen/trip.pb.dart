// This is a generated file - do not edit.
//
// Generated from trip.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'trip.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'trip.pbenum.dart';

class CreateTripRequest extends $pb.GeneratedMessage {
  factory CreateTripRequest({
    $core.String? pickupAddress,
    $core.String? destAddress,
    $core.double? pickupLat,
    $core.double? pickupLng,
    $core.double? destLat,
    $core.double? destLng,
    $fixnum.Int64? priceKzt,
  }) {
    final result = create();
    if (pickupAddress != null) result.pickupAddress = pickupAddress;
    if (destAddress != null) result.destAddress = destAddress;
    if (pickupLat != null) result.pickupLat = pickupLat;
    if (pickupLng != null) result.pickupLng = pickupLng;
    if (destLat != null) result.destLat = destLat;
    if (destLng != null) result.destLng = destLng;
    if (priceKzt != null) result.priceKzt = priceKzt;
    return result;
  }

  CreateTripRequest._();

  factory CreateTripRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTripRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTripRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pickupAddress')
    ..aOS(2, _omitFieldNames ? '' : 'destAddress')
    ..aD(3, _omitFieldNames ? '' : 'pickupLat')
    ..aD(4, _omitFieldNames ? '' : 'pickupLng')
    ..aD(5, _omitFieldNames ? '' : 'destLat')
    ..aD(6, _omitFieldNames ? '' : 'destLng')
    ..aInt64(7, _omitFieldNames ? '' : 'priceKzt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTripRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTripRequest copyWith(void Function(CreateTripRequest) updates) =>
      super.copyWith((message) => updates(message as CreateTripRequest))
          as CreateTripRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTripRequest create() => CreateTripRequest._();
  @$core.override
  CreateTripRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTripRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTripRequest>(create);
  static CreateTripRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pickupAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set pickupAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPickupAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearPickupAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get destAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set destAddress($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDestAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearDestAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get pickupLat => $_getN(2);
  @$pb.TagNumber(3)
  set pickupLat($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPickupLat() => $_has(2);
  @$pb.TagNumber(3)
  void clearPickupLat() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get pickupLng => $_getN(3);
  @$pb.TagNumber(4)
  set pickupLng($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPickupLng() => $_has(3);
  @$pb.TagNumber(4)
  void clearPickupLng() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get destLat => $_getN(4);
  @$pb.TagNumber(5)
  set destLat($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDestLat() => $_has(4);
  @$pb.TagNumber(5)
  void clearDestLat() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get destLng => $_getN(5);
  @$pb.TagNumber(6)
  set destLng($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDestLng() => $_has(5);
  @$pb.TagNumber(6)
  void clearDestLng() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get priceKzt => $_getI64(6);
  @$pb.TagNumber(7)
  set priceKzt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPriceKzt() => $_has(6);
  @$pb.TagNumber(7)
  void clearPriceKzt() => $_clearField(7);
}

class AcceptTripRequest extends $pb.GeneratedMessage {
  factory AcceptTripRequest({
    $core.String? tripId,
  }) {
    final result = create();
    if (tripId != null) result.tripId = tripId;
    return result;
  }

  AcceptTripRequest._();

  factory AcceptTripRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AcceptTripRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AcceptTripRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tripId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptTripRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptTripRequest copyWith(void Function(AcceptTripRequest) updates) =>
      super.copyWith((message) => updates(message as AcceptTripRequest))
          as AcceptTripRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcceptTripRequest create() => AcceptTripRequest._();
  @$core.override
  AcceptTripRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AcceptTripRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AcceptTripRequest>(create);
  static AcceptTripRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tripId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tripId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTripId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTripId() => $_clearField(1);
}

class GetTripRequest extends $pb.GeneratedMessage {
  factory GetTripRequest({
    $core.String? tripId,
  }) {
    final result = create();
    if (tripId != null) result.tripId = tripId;
    return result;
  }

  GetTripRequest._();

  factory GetTripRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTripRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTripRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tripId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTripRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTripRequest copyWith(void Function(GetTripRequest) updates) =>
      super.copyWith((message) => updates(message as GetTripRequest))
          as GetTripRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTripRequest create() => GetTripRequest._();
  @$core.override
  GetTripRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTripRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTripRequest>(create);
  static GetTripRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tripId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tripId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTripId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTripId() => $_clearField(1);
}

class TripResponse extends $pb.GeneratedMessage {
  factory TripResponse({
    $core.String? tripId,
    $core.String? passengerId,
    $core.String? driverId,
    TripStatus? status,
    $core.String? pickupAddress,
    $core.String? destAddress,
    $core.double? pickupLat,
    $core.double? pickupLng,
    $core.double? destLat,
    $core.double? destLng,
    $fixnum.Int64? priceKzt,
  }) {
    final result = create();
    if (tripId != null) result.tripId = tripId;
    if (passengerId != null) result.passengerId = passengerId;
    if (driverId != null) result.driverId = driverId;
    if (status != null) result.status = status;
    if (pickupAddress != null) result.pickupAddress = pickupAddress;
    if (destAddress != null) result.destAddress = destAddress;
    if (pickupLat != null) result.pickupLat = pickupLat;
    if (pickupLng != null) result.pickupLng = pickupLng;
    if (destLat != null) result.destLat = destLat;
    if (destLng != null) result.destLng = destLng;
    if (priceKzt != null) result.priceKzt = priceKzt;
    return result;
  }

  TripResponse._();

  factory TripResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TripResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TripResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tripId')
    ..aOS(2, _omitFieldNames ? '' : 'passengerId')
    ..aOS(3, _omitFieldNames ? '' : 'driverId')
    ..aE<TripStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: TripStatus.values)
    ..aOS(5, _omitFieldNames ? '' : 'pickupAddress')
    ..aOS(6, _omitFieldNames ? '' : 'destAddress')
    ..aD(7, _omitFieldNames ? '' : 'pickupLat')
    ..aD(8, _omitFieldNames ? '' : 'pickupLng')
    ..aD(9, _omitFieldNames ? '' : 'destLat')
    ..aD(10, _omitFieldNames ? '' : 'destLng')
    ..aInt64(11, _omitFieldNames ? '' : 'priceKzt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripResponse copyWith(void Function(TripResponse) updates) =>
      super.copyWith((message) => updates(message as TripResponse))
          as TripResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TripResponse create() => TripResponse._();
  @$core.override
  TripResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TripResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TripResponse>(create);
  static TripResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tripId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tripId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTripId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTripId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get passengerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set passengerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassengerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassengerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get driverId => $_getSZ(2);
  @$pb.TagNumber(3)
  set driverId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDriverId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDriverId() => $_clearField(3);

  @$pb.TagNumber(4)
  TripStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(TripStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get pickupAddress => $_getSZ(4);
  @$pb.TagNumber(5)
  set pickupAddress($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPickupAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearPickupAddress() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get destAddress => $_getSZ(5);
  @$pb.TagNumber(6)
  set destAddress($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDestAddress() => $_has(5);
  @$pb.TagNumber(6)
  void clearDestAddress() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get pickupLat => $_getN(6);
  @$pb.TagNumber(7)
  set pickupLat($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPickupLat() => $_has(6);
  @$pb.TagNumber(7)
  void clearPickupLat() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get pickupLng => $_getN(7);
  @$pb.TagNumber(8)
  set pickupLng($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPickupLng() => $_has(7);
  @$pb.TagNumber(8)
  void clearPickupLng() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get destLat => $_getN(8);
  @$pb.TagNumber(9)
  set destLat($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDestLat() => $_has(8);
  @$pb.TagNumber(9)
  void clearDestLat() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get destLng => $_getN(9);
  @$pb.TagNumber(10)
  set destLng($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDestLng() => $_has(9);
  @$pb.TagNumber(10)
  void clearDestLng() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get priceKzt => $_getI64(10);
  @$pb.TagNumber(11)
  set priceKzt($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPriceKzt() => $_has(10);
  @$pb.TagNumber(11)
  void clearPriceKzt() => $_clearField(11);
}

class LocationRequest extends $pb.GeneratedMessage {
  factory LocationRequest({
    $core.String? tripId,
    $core.double? lat,
    $core.double? lng,
  }) {
    final result = create();
    if (tripId != null) result.tripId = tripId;
    if (lat != null) result.lat = lat;
    if (lng != null) result.lng = lng;
    return result;
  }

  LocationRequest._();

  factory LocationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LocationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LocationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tripId')
    ..aD(2, _omitFieldNames ? '' : 'lat')
    ..aD(3, _omitFieldNames ? '' : 'lng')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationRequest copyWith(void Function(LocationRequest) updates) =>
      super.copyWith((message) => updates(message as LocationRequest))
          as LocationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationRequest create() => LocationRequest._();
  @$core.override
  LocationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LocationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LocationRequest>(create);
  static LocationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tripId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tripId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTripId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTripId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get lat => $_getN(1);
  @$pb.TagNumber(2)
  set lat($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLat() => $_has(1);
  @$pb.TagNumber(2)
  void clearLat() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get lng => $_getN(2);
  @$pb.TagNumber(3)
  set lng($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLng() => $_has(2);
  @$pb.TagNumber(3)
  void clearLng() => $_clearField(3);
}

class TrackRequest extends $pb.GeneratedMessage {
  factory TrackRequest({
    $core.String? tripId,
  }) {
    final result = create();
    if (tripId != null) result.tripId = tripId;
    return result;
  }

  TrackRequest._();

  factory TrackRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TrackRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrackRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tripId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrackRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrackRequest copyWith(void Function(TrackRequest) updates) =>
      super.copyWith((message) => updates(message as TrackRequest))
          as TrackRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrackRequest create() => TrackRequest._();
  @$core.override
  TrackRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TrackRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TrackRequest>(create);
  static TrackRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tripId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tripId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTripId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTripId() => $_clearField(1);
}

class LocationResponse extends $pb.GeneratedMessage {
  factory LocationResponse({
    $core.double? lat,
    $core.double? lng,
  }) {
    final result = create();
    if (lat != null) result.lat = lat;
    if (lng != null) result.lng = lng;
    return result;
  }

  LocationResponse._();

  factory LocationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LocationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LocationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'lat')
    ..aD(2, _omitFieldNames ? '' : 'lng')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationResponse copyWith(void Function(LocationResponse) updates) =>
      super.copyWith((message) => updates(message as LocationResponse))
          as LocationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationResponse create() => LocationResponse._();
  @$core.override
  LocationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LocationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LocationResponse>(create);
  static LocationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get lat => $_getN(0);
  @$pb.TagNumber(1)
  set lat($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLat() => $_has(0);
  @$pb.TagNumber(1)
  void clearLat() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get lng => $_getN(1);
  @$pb.TagNumber(2)
  set lng($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLng() => $_has(1);
  @$pb.TagNumber(2)
  void clearLng() => $_clearField(2);
}

class EstimateRequest extends $pb.GeneratedMessage {
  factory EstimateRequest({
    $core.double? pickupLat,
    $core.double? pickupLng,
    $core.double? destLat,
    $core.double? destLng,
  }) {
    final result = create();
    if (pickupLat != null) result.pickupLat = pickupLat;
    if (pickupLng != null) result.pickupLng = pickupLng;
    if (destLat != null) result.destLat = destLat;
    if (destLng != null) result.destLng = destLng;
    return result;
  }

  EstimateRequest._();

  factory EstimateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EstimateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EstimateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'pickupLat')
    ..aD(2, _omitFieldNames ? '' : 'pickupLng')
    ..aD(3, _omitFieldNames ? '' : 'destLat')
    ..aD(4, _omitFieldNames ? '' : 'destLng')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateRequest copyWith(void Function(EstimateRequest) updates) =>
      super.copyWith((message) => updates(message as EstimateRequest))
          as EstimateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EstimateRequest create() => EstimateRequest._();
  @$core.override
  EstimateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EstimateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EstimateRequest>(create);
  static EstimateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get pickupLat => $_getN(0);
  @$pb.TagNumber(1)
  set pickupLat($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPickupLat() => $_has(0);
  @$pb.TagNumber(1)
  void clearPickupLat() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get pickupLng => $_getN(1);
  @$pb.TagNumber(2)
  set pickupLng($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPickupLng() => $_has(1);
  @$pb.TagNumber(2)
  void clearPickupLng() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get destLat => $_getN(2);
  @$pb.TagNumber(3)
  set destLat($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDestLat() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestLat() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get destLng => $_getN(3);
  @$pb.TagNumber(4)
  set destLng($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDestLng() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestLng() => $_clearField(4);
}

class EstimateResponse extends $pb.GeneratedMessage {
  factory EstimateResponse({
    $core.int? priceKzt,
    $core.double? distanceKm,
  }) {
    final result = create();
    if (priceKzt != null) result.priceKzt = priceKzt;
    if (distanceKm != null) result.distanceKm = distanceKm;
    return result;
  }

  EstimateResponse._();

  factory EstimateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EstimateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EstimateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trip'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'priceKzt')
    ..aD(2, _omitFieldNames ? '' : 'distanceKm')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateResponse copyWith(void Function(EstimateResponse) updates) =>
      super.copyWith((message) => updates(message as EstimateResponse))
          as EstimateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EstimateResponse create() => EstimateResponse._();
  @$core.override
  EstimateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EstimateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EstimateResponse>(create);
  static EstimateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get priceKzt => $_getIZ(0);
  @$pb.TagNumber(1)
  set priceKzt($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPriceKzt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceKzt() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get distanceKm => $_getN(1);
  @$pb.TagNumber(2)
  set distanceKm($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDistanceKm() => $_has(1);
  @$pb.TagNumber(2)
  void clearDistanceKm() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
