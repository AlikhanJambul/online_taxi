// This is a generated file - do not edit.
//
// Generated from trip.proto.

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

@$core.Deprecated('Use tripStatusDescriptor instead')
const TripStatus$json = {
  '1': 'TripStatus',
  '2': [
    {'1': 'STATUS_UNSPECIFIED', '2': 0},
    {'1': 'SEARCHING', '2': 1},
    {'1': 'ACCEPTED', '2': 2},
    {'1': 'ARRIVED', '2': 3},
    {'1': 'IN_PROGRESS', '2': 4},
    {'1': 'COMPLETED', '2': 5},
    {'1': 'CANCELLED', '2': 6},
  ],
};

/// Descriptor for `TripStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tripStatusDescriptor = $convert.base64Decode(
    'CgpUcmlwU3RhdHVzEhYKElNUQVRVU19VTlNQRUNJRklFRBAAEg0KCVNFQVJDSElORxABEgwKCE'
    'FDQ0VQVEVEEAISCwoHQVJSSVZFRBADEg8KC0lOX1BST0dSRVNTEAQSDQoJQ09NUExFVEVEEAUS'
    'DQoJQ0FOQ0VMTEVEEAY=');

@$core.Deprecated('Use createTripRequestDescriptor instead')
const CreateTripRequest$json = {
  '1': 'CreateTripRequest',
  '2': [
    {'1': 'pickup_address', '3': 1, '4': 1, '5': 9, '10': 'pickupAddress'},
    {'1': 'dest_address', '3': 2, '4': 1, '5': 9, '10': 'destAddress'},
    {'1': 'pickup_lat', '3': 3, '4': 1, '5': 1, '10': 'pickupLat'},
    {'1': 'pickup_lng', '3': 4, '4': 1, '5': 1, '10': 'pickupLng'},
    {'1': 'dest_lat', '3': 5, '4': 1, '5': 1, '10': 'destLat'},
    {'1': 'dest_lng', '3': 6, '4': 1, '5': 1, '10': 'destLng'},
    {'1': 'price_kzt', '3': 7, '4': 1, '5': 3, '10': 'priceKzt'},
  ],
};

/// Descriptor for `CreateTripRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTripRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVUcmlwUmVxdWVzdBIlCg5waWNrdXBfYWRkcmVzcxgBIAEoCVINcGlja3VwQWRkcm'
    'VzcxIhCgxkZXN0X2FkZHJlc3MYAiABKAlSC2Rlc3RBZGRyZXNzEh0KCnBpY2t1cF9sYXQYAyAB'
    'KAFSCXBpY2t1cExhdBIdCgpwaWNrdXBfbG5nGAQgASgBUglwaWNrdXBMbmcSGQoIZGVzdF9sYX'
    'QYBSABKAFSB2Rlc3RMYXQSGQoIZGVzdF9sbmcYBiABKAFSB2Rlc3RMbmcSGwoJcHJpY2Vfa3p0'
    'GAcgASgDUghwcmljZUt6dA==');

@$core.Deprecated('Use acceptTripRequestDescriptor instead')
const AcceptTripRequest$json = {
  '1': 'AcceptTripRequest',
  '2': [
    {'1': 'trip_id', '3': 1, '4': 1, '5': 9, '10': 'tripId'},
  ],
};

/// Descriptor for `AcceptTripRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acceptTripRequestDescriptor = $convert.base64Decode(
    'ChFBY2NlcHRUcmlwUmVxdWVzdBIXCgd0cmlwX2lkGAEgASgJUgZ0cmlwSWQ=');

@$core.Deprecated('Use getTripRequestDescriptor instead')
const GetTripRequest$json = {
  '1': 'GetTripRequest',
  '2': [
    {'1': 'trip_id', '3': 1, '4': 1, '5': 9, '10': 'tripId'},
  ],
};

/// Descriptor for `GetTripRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTripRequestDescriptor = $convert
    .base64Decode('Cg5HZXRUcmlwUmVxdWVzdBIXCgd0cmlwX2lkGAEgASgJUgZ0cmlwSWQ=');

@$core.Deprecated('Use tripResponseDescriptor instead')
const TripResponse$json = {
  '1': 'TripResponse',
  '2': [
    {'1': 'trip_id', '3': 1, '4': 1, '5': 9, '10': 'tripId'},
    {'1': 'passenger_id', '3': 2, '4': 1, '5': 9, '10': 'passengerId'},
    {'1': 'driver_id', '3': 3, '4': 1, '5': 9, '10': 'driverId'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.trip.TripStatus',
      '10': 'status'
    },
    {'1': 'pickup_address', '3': 5, '4': 1, '5': 9, '10': 'pickupAddress'},
    {'1': 'dest_address', '3': 6, '4': 1, '5': 9, '10': 'destAddress'},
    {'1': 'pickup_lat', '3': 7, '4': 1, '5': 1, '10': 'pickupLat'},
    {'1': 'pickup_lng', '3': 8, '4': 1, '5': 1, '10': 'pickupLng'},
    {'1': 'dest_lat', '3': 9, '4': 1, '5': 1, '10': 'destLat'},
    {'1': 'dest_lng', '3': 10, '4': 1, '5': 1, '10': 'destLng'},
    {'1': 'price_kzt', '3': 11, '4': 1, '5': 3, '10': 'priceKzt'},
  ],
};

/// Descriptor for `TripResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripResponseDescriptor = $convert.base64Decode(
    'CgxUcmlwUmVzcG9uc2USFwoHdHJpcF9pZBgBIAEoCVIGdHJpcElkEiEKDHBhc3Nlbmdlcl9pZB'
    'gCIAEoCVILcGFzc2VuZ2VySWQSGwoJZHJpdmVyX2lkGAMgASgJUghkcml2ZXJJZBIoCgZzdGF0'
    'dXMYBCABKA4yEC50cmlwLlRyaXBTdGF0dXNSBnN0YXR1cxIlCg5waWNrdXBfYWRkcmVzcxgFIA'
    'EoCVINcGlja3VwQWRkcmVzcxIhCgxkZXN0X2FkZHJlc3MYBiABKAlSC2Rlc3RBZGRyZXNzEh0K'
    'CnBpY2t1cF9sYXQYByABKAFSCXBpY2t1cExhdBIdCgpwaWNrdXBfbG5nGAggASgBUglwaWNrdX'
    'BMbmcSGQoIZGVzdF9sYXQYCSABKAFSB2Rlc3RMYXQSGQoIZGVzdF9sbmcYCiABKAFSB2Rlc3RM'
    'bmcSGwoJcHJpY2Vfa3p0GAsgASgDUghwcmljZUt6dA==');

@$core.Deprecated('Use locationRequestDescriptor instead')
const LocationRequest$json = {
  '1': 'LocationRequest',
  '2': [
    {'1': 'trip_id', '3': 1, '4': 1, '5': 9, '10': 'tripId'},
    {'1': 'lat', '3': 2, '4': 1, '5': 1, '10': 'lat'},
    {'1': 'lng', '3': 3, '4': 1, '5': 1, '10': 'lng'},
  ],
};

/// Descriptor for `LocationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationRequestDescriptor = $convert.base64Decode(
    'Cg9Mb2NhdGlvblJlcXVlc3QSFwoHdHJpcF9pZBgBIAEoCVIGdHJpcElkEhAKA2xhdBgCIAEoAV'
    'IDbGF0EhAKA2xuZxgDIAEoAVIDbG5n');

@$core.Deprecated('Use trackRequestDescriptor instead')
const TrackRequest$json = {
  '1': 'TrackRequest',
  '2': [
    {'1': 'trip_id', '3': 1, '4': 1, '5': 9, '10': 'tripId'},
  ],
};

/// Descriptor for `TrackRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trackRequestDescriptor = $convert
    .base64Decode('CgxUcmFja1JlcXVlc3QSFwoHdHJpcF9pZBgBIAEoCVIGdHJpcElk');

@$core.Deprecated('Use locationResponseDescriptor instead')
const LocationResponse$json = {
  '1': 'LocationResponse',
  '2': [
    {'1': 'lat', '3': 1, '4': 1, '5': 1, '10': 'lat'},
    {'1': 'lng', '3': 2, '4': 1, '5': 1, '10': 'lng'},
  ],
};

/// Descriptor for `LocationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationResponseDescriptor = $convert.base64Decode(
    'ChBMb2NhdGlvblJlc3BvbnNlEhAKA2xhdBgBIAEoAVIDbGF0EhAKA2xuZxgCIAEoAVIDbG5n');

@$core.Deprecated('Use estimateRequestDescriptor instead')
const EstimateRequest$json = {
  '1': 'EstimateRequest',
  '2': [
    {'1': 'pickup_lat', '3': 1, '4': 1, '5': 1, '10': 'pickupLat'},
    {'1': 'pickup_lng', '3': 2, '4': 1, '5': 1, '10': 'pickupLng'},
    {'1': 'dest_lat', '3': 3, '4': 1, '5': 1, '10': 'destLat'},
    {'1': 'dest_lng', '3': 4, '4': 1, '5': 1, '10': 'destLng'},
  ],
};

/// Descriptor for `EstimateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateRequestDescriptor = $convert.base64Decode(
    'Cg9Fc3RpbWF0ZVJlcXVlc3QSHQoKcGlja3VwX2xhdBgBIAEoAVIJcGlja3VwTGF0Eh0KCnBpY2'
    't1cF9sbmcYAiABKAFSCXBpY2t1cExuZxIZCghkZXN0X2xhdBgDIAEoAVIHZGVzdExhdBIZCghk'
    'ZXN0X2xuZxgEIAEoAVIHZGVzdExuZw==');

@$core.Deprecated('Use estimateResponseDescriptor instead')
const EstimateResponse$json = {
  '1': 'EstimateResponse',
  '2': [
    {'1': 'price_kzt', '3': 1, '4': 1, '5': 5, '10': 'priceKzt'},
    {'1': 'distance_km', '3': 2, '4': 1, '5': 1, '10': 'distanceKm'},
  ],
};

/// Descriptor for `EstimateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateResponseDescriptor = $convert.base64Decode(
    'ChBFc3RpbWF0ZVJlc3BvbnNlEhsKCXByaWNlX2t6dBgBIAEoBVIIcHJpY2VLenQSHwoLZGlzdG'
    'FuY2Vfa20YAiABKAFSCmRpc3RhbmNlS20=');
