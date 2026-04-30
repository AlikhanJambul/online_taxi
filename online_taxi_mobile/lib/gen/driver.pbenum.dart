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

class DriverStatus extends $pb.ProtobufEnum {
  static const DriverStatus STATUS_UNSPECIFIED =
      DriverStatus._(0, _omitEnumNames ? '' : 'STATUS_UNSPECIFIED');
  static const DriverStatus PENDING =
      DriverStatus._(1, _omitEnumNames ? '' : 'PENDING');
  static const DriverStatus APPROVED =
      DriverStatus._(2, _omitEnumNames ? '' : 'APPROVED');
  static const DriverStatus REJECTED =
      DriverStatus._(3, _omitEnumNames ? '' : 'REJECTED');

  static const $core.List<DriverStatus> values = <DriverStatus>[
    STATUS_UNSPECIFIED,
    PENDING,
    APPROVED,
    REJECTED,
  ];

  static final $core.List<DriverStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DriverStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DriverStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
