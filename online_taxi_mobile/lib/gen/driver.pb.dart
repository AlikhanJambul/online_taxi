// This is a generated file - do not edit.
//
// Generated from driver.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'driver.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'driver.pbenum.dart';

class CreateProfileRequest extends $pb.GeneratedMessage {
  factory CreateProfileRequest({
    $core.String? carMake,
    $core.String? carModel,
    $core.String? carColor,
    $core.String? licensePlate,
  }) {
    final result = create();
    if (carMake != null) result.carMake = carMake;
    if (carModel != null) result.carModel = carModel;
    if (carColor != null) result.carColor = carColor;
    if (licensePlate != null) result.licensePlate = licensePlate;
    return result;
  }

  CreateProfileRequest._();

  factory CreateProfileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateProfileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProfileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'driver'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'carMake')
    ..aOS(2, _omitFieldNames ? '' : 'carModel')
    ..aOS(3, _omitFieldNames ? '' : 'carColor')
    ..aOS(4, _omitFieldNames ? '' : 'licensePlate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProfileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProfileRequest copyWith(void Function(CreateProfileRequest) updates) =>
      super.copyWith((message) => updates(message as CreateProfileRequest))
          as CreateProfileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProfileRequest create() => CreateProfileRequest._();
  @$core.override
  CreateProfileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateProfileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProfileRequest>(create);
  static CreateProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get carMake => $_getSZ(0);
  @$pb.TagNumber(1)
  set carMake($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCarMake() => $_has(0);
  @$pb.TagNumber(1)
  void clearCarMake() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get carModel => $_getSZ(1);
  @$pb.TagNumber(2)
  set carModel($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCarModel() => $_has(1);
  @$pb.TagNumber(2)
  void clearCarModel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get carColor => $_getSZ(2);
  @$pb.TagNumber(3)
  set carColor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCarColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCarColor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get licensePlate => $_getSZ(3);
  @$pb.TagNumber(4)
  set licensePlate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLicensePlate() => $_has(3);
  @$pb.TagNumber(4)
  void clearLicensePlate() => $_clearField(4);
}

class DriverProfileResponse extends $pb.GeneratedMessage {
  factory DriverProfileResponse({
    $core.String? userId,
    $core.String? carMake,
    $core.String? carModel,
    $core.String? carColor,
    $core.String? licensePlate,
    $core.String? carUrl,
    DriverStatus? status,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (carMake != null) result.carMake = carMake;
    if (carModel != null) result.carModel = carModel;
    if (carColor != null) result.carColor = carColor;
    if (licensePlate != null) result.licensePlate = licensePlate;
    if (carUrl != null) result.carUrl = carUrl;
    if (status != null) result.status = status;
    return result;
  }

  DriverProfileResponse._();

  factory DriverProfileResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DriverProfileResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DriverProfileResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'driver'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'carMake')
    ..aOS(3, _omitFieldNames ? '' : 'carModel')
    ..aOS(4, _omitFieldNames ? '' : 'carColor')
    ..aOS(5, _omitFieldNames ? '' : 'licensePlate')
    ..aOS(6, _omitFieldNames ? '' : 'carUrl')
    ..aE<DriverStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: DriverStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DriverProfileResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DriverProfileResponse copyWith(
          void Function(DriverProfileResponse) updates) =>
      super.copyWith((message) => updates(message as DriverProfileResponse))
          as DriverProfileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DriverProfileResponse create() => DriverProfileResponse._();
  @$core.override
  DriverProfileResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DriverProfileResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DriverProfileResponse>(create);
  static DriverProfileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get carMake => $_getSZ(1);
  @$pb.TagNumber(2)
  set carMake($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCarMake() => $_has(1);
  @$pb.TagNumber(2)
  void clearCarMake() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get carModel => $_getSZ(2);
  @$pb.TagNumber(3)
  set carModel($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCarModel() => $_has(2);
  @$pb.TagNumber(3)
  void clearCarModel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get carColor => $_getSZ(3);
  @$pb.TagNumber(4)
  set carColor($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCarColor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCarColor() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get licensePlate => $_getSZ(4);
  @$pb.TagNumber(5)
  set licensePlate($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLicensePlate() => $_has(4);
  @$pb.TagNumber(5)
  void clearLicensePlate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get carUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set carUrl($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCarUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearCarUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  DriverStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(DriverStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
