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
    {'1': 'car_photo_url', '3': 5, '4': 1, '5': 9, '10': 'carPhotoUrl'},
  ],
};

/// Descriptor for `CreateProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProfileRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVQcm9maWxlUmVxdWVzdBIZCghjYXJfbWFrZRgBIAEoCVIHY2FyTWFrZRIbCgljYX'
    'JfbW9kZWwYAiABKAlSCGNhck1vZGVsEhsKCWNhcl9jb2xvchgDIAEoCVIIY2FyQ29sb3ISIwoN'
    'bGljZW5zZV9wbGF0ZRgEIAEoCVIMbGljZW5zZVBsYXRlEiIKDWNhcl9waG90b191cmwYBSABKA'
    'lSC2NhclBob3RvVXJs');

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
    {'1': 'rating', '3': 8, '4': 1, '5': 1, '10': 'rating'},
    {'1': 'total_trips', '3': 9, '4': 1, '5': 5, '10': 'totalTrips'},
    {
      '1': 'total_earnings_kzt',
      '3': 10,
      '4': 1,
      '5': 3,
      '10': 'totalEarningsKzt'
    },
  ],
};

/// Descriptor for `DriverProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List driverProfileResponseDescriptor = $convert.base64Decode(
    'ChVEcml2ZXJQcm9maWxlUmVzcG9uc2USFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhkKCGNhcl'
    '9tYWtlGAIgASgJUgdjYXJNYWtlEhsKCWNhcl9tb2RlbBgDIAEoCVIIY2FyTW9kZWwSGwoJY2Fy'
    'X2NvbG9yGAQgASgJUghjYXJDb2xvchIjCg1saWNlbnNlX3BsYXRlGAUgASgJUgxsaWNlbnNlUG'
    'xhdGUSFwoHY2FyX3VybBgGIAEoCVIGY2FyVXJsEiwKBnN0YXR1cxgHIAEoDjIULmRyaXZlci5E'
    'cml2ZXJTdGF0dXNSBnN0YXR1cxIWCgZyYXRpbmcYCCABKAFSBnJhdGluZxIfCgt0b3RhbF90cm'
    'lwcxgJIAEoBVIKdG90YWxUcmlwcxIsChJ0b3RhbF9lYXJuaW5nc19renQYCiABKANSEHRvdGFs'
    'RWFybmluZ3NLenQ=');

@$core.Deprecated('Use getUploadURLResponseDescriptor instead')
const GetUploadURLResponse$json = {
  '1': 'GetUploadURLResponse',
  '2': [
    {'1': 'upload_url', '3': 1, '4': 1, '5': 9, '10': 'uploadUrl'},
    {'1': 'file_url', '3': 2, '4': 1, '5': 9, '10': 'fileUrl'},
  ],
};

/// Descriptor for `GetUploadURLResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUploadURLResponseDescriptor = $convert.base64Decode(
    'ChRHZXRVcGxvYWRVUkxSZXNwb25zZRIdCgp1cGxvYWRfdXJsGAEgASgJUgl1cGxvYWRVcmwSGQ'
    'oIZmlsZV91cmwYAiABKAlSB2ZpbGVVcmw=');

@$core.Deprecated('Use tripHistoryItemPbDescriptor instead')
const TripHistoryItemPb$json = {
  '1': 'TripHistoryItemPb',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'pickup_address', '3': 2, '4': 1, '5': 9, '10': 'pickupAddress'},
    {'1': 'dest_address', '3': 3, '4': 1, '5': 9, '10': 'destAddress'},
    {'1': 'price_kzt', '3': 4, '4': 1, '5': 3, '10': 'priceKzt'},
    {'1': 'finished_at', '3': 5, '4': 1, '5': 9, '10': 'finishedAt'},
  ],
};

/// Descriptor for `TripHistoryItemPb`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripHistoryItemPbDescriptor = $convert.base64Decode(
    'ChFUcmlwSGlzdG9yeUl0ZW1QYhIOCgJpZBgBIAEoCVICaWQSJQoOcGlja3VwX2FkZHJlc3MYAi'
    'ABKAlSDXBpY2t1cEFkZHJlc3MSIQoMZGVzdF9hZGRyZXNzGAMgASgJUgtkZXN0QWRkcmVzcxIb'
    'CglwcmljZV9renQYBCABKANSCHByaWNlS3p0Eh8KC2ZpbmlzaGVkX2F0GAUgASgJUgpmaW5pc2'
    'hlZEF0');

@$core.Deprecated('Use tripHistoryResponseDescriptor instead')
const TripHistoryResponse$json = {
  '1': 'TripHistoryResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.driver.TripHistoryItemPb',
      '10': 'items'
    },
  ],
};

/// Descriptor for `TripHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripHistoryResponseDescriptor = $convert.base64Decode(
    'ChNUcmlwSGlzdG9yeVJlc3BvbnNlEi8KBWl0ZW1zGAEgAygLMhkuZHJpdmVyLlRyaXBIaXN0b3'
    'J5SXRlbVBiUgVpdGVtcw==');
