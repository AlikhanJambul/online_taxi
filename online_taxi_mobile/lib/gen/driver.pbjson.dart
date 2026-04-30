// This is a generated file - do not edit.
//
// Generated from driver.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use driverStatusDescriptor instead')
const DriverStatus$json = {
  '1': 'DriverStatus',
  '2': [
    {'1': 'STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PENDING', '2': 1},
    {'1': 'APPROVED', '2': 2},
    {'1': 'REJECTED', '2': 3},
  ],
};

/// Descriptor for `DriverStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List driverStatusDescriptor = $convert.base64Decode(
    'CgxEcml2ZXJTdGF0dXMSFgoSU1RBVFVTX1VOU1BFQ0lGSUVEEAASCwoHUEVORElORxABEgwKCE'
    'FQUFJPVkVEEAISDAoIUkVKRUNURUQQAw==');

@$core.Deprecated('Use createProfileRequestDescriptor instead')
const CreateProfileRequest$json = {
  '1': 'CreateProfileRequest',
  '2': [
    {'1': 'car_make', '3': 1, '4': 1, '5': 9, '10': 'carMake'},
    {'1': 'car_model', '3': 2, '4': 1, '5': 9, '10': 'carModel'},
    {'1': 'car_color', '3': 3, '4': 1, '5': 9, '10': 'carColor'},
    {'1': 'license_plate', '3': 4, '4': 1, '5': 9, '10': 'licensePlate'},
  ],
};

/// Descriptor for `CreateProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProfileRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVQcm9maWxlUmVxdWVzdBIZCghjYXJfbWFrZRgBIAEoCVIHY2FyTWFrZRIbCgljYX'
    'JfbW9kZWwYAiABKAlSCGNhck1vZGVsEhsKCWNhcl9jb2xvchgDIAEoCVIIY2FyQ29sb3ISIwoN'
    'bGljZW5zZV9wbGF0ZRgEIAEoCVIMbGljZW5zZVBsYXRl');

@$core.Deprecated('Use driverProfileResponseDescriptor instead')
const DriverProfileResponse$json = {
  '1': 'DriverProfileResponse',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'car_make', '3': 2, '4': 1, '5': 9, '10': 'carMake'},
    {'1': 'car_model', '3': 3, '4': 1, '5': 9, '10': 'carModel'},
    {'1': 'car_color', '3': 4, '4': 1, '5': 9, '10': 'carColor'},
    {'1': 'license_plate', '3': 5, '4': 1, '5': 9, '10': 'licensePlate'},
    {'1': 'car_url', '3': 6, '4': 1, '5': 9, '10': 'carUrl'},
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.driver.DriverStatus',
      '10': 'status'
    },
  ],
};

/// Descriptor for `DriverProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List driverProfileResponseDescriptor = $convert.base64Decode(
    'ChVEcml2ZXJQcm9maWxlUmVzcG9uc2USFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhkKCGNhcl'
    '9tYWtlGAIgASgJUgdjYXJNYWtlEhsKCWNhcl9tb2RlbBgDIAEoCVIIY2FyTW9kZWwSGwoJY2Fy'
    'X2NvbG9yGAQgASgJUghjYXJDb2xvchIjCg1saWNlbnNlX3BsYXRlGAUgASgJUgxsaWNlbnNlUG'
    'xhdGUSFwoHY2FyX3VybBgGIAEoCVIGY2FyVXJsEiwKBnN0YXR1cxgHIAEoDjIULmRyaXZlci5E'
    'cml2ZXJTdGF0dXNSBnN0YXR1cw==');
