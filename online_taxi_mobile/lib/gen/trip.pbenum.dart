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

import 'package:protobuf/protobuf.dart' as $pb;

class TripStatus extends $pb.ProtobufEnum {
  static const TripStatus STATUS_UNSPECIFIED =
      TripStatus._(0, _omitEnumNames ? '' : 'STATUS_UNSPECIFIED');
  static const TripStatus SEARCHING =
      TripStatus._(1, _omitEnumNames ? '' : 'SEARCHING');
  static const TripStatus ACCEPTED =
      TripStatus._(2, _omitEnumNames ? '' : 'ACCEPTED');
  static const TripStatus ARRIVED =
      TripStatus._(3, _omitEnumNames ? '' : 'ARRIVED');
  static const TripStatus IN_PROGRESS =
      TripStatus._(4, _omitEnumNames ? '' : 'IN_PROGRESS');
  static const TripStatus COMPLETED =
      TripStatus._(5, _omitEnumNames ? '' : 'COMPLETED');
  static const TripStatus CANCELLED =
      TripStatus._(6, _omitEnumNames ? '' : 'CANCELLED');

  static const $core.List<TripStatus> values = <TripStatus>[
    STATUS_UNSPECIFIED,
    SEARCHING,
    ACCEPTED,
    ARRIVED,
    IN_PROGRESS,
    COMPLETED,
    CANCELLED,
  ];

  static final $core.List<TripStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static TripStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TripStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
