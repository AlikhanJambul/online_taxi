// This is a generated file - do not edit.
//
// Generated from auth.proto.

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

@$core.Deprecated('Use roleDescriptor instead')
const Role$json = {
  '1': 'Role',
  '2': [
    {'1': 'ROLE_UNSPECIFIED', '2': 0},
    {'1': 'PASSENGER', '2': 1},
    {'1': 'DRIVER', '2': 2},
    {'1': 'ADMIN', '2': 3},
  ],
};

/// Descriptor for `Role`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List roleDescriptor = $convert.base64Decode(
    'CgRSb2xlEhQKEFJPTEVfVU5TUEVDSUZJRUQQABINCglQQVNTRU5HRVIQARIKCgZEUklWRVIQAh'
    'IJCgVBRE1JThAD');

@$core.Deprecated('Use registerRequestDescriptor instead')
const RegisterRequest$json = {
  '1': 'RegisterRequest',
  '2': [
    {'1': 'phone', '3': 1, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'full_name', '3': 3, '4': 1, '5': 9, '10': 'fullName'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '10': 'email'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.auth.Role', '10': 'role'},
    {'1': 'device_id', '3': 6, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `RegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerRequestDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclJlcXVlc3QSFAoFcGhvbmUYASABKAlSBXBob25lEhoKCHBhc3N3b3JkGAIgAS'
    'gJUghwYXNzd29yZBIbCglmdWxsX25hbWUYAyABKAlSCGZ1bGxOYW1lEhQKBWVtYWlsGAQgASgJ'
    'UgVlbWFpbBIeCgRyb2xlGAUgASgOMgouYXV0aC5Sb2xlUgRyb2xlEhsKCWRldmljZV9pZBgGIA'
    'EoCVIIZGV2aWNlSWQ=');

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSFAoFZW1haWwYASABKAlSBWVtYWlsEhoKCHBhc3N3b3JkGAIgASgJUg'
    'hwYXNzd29yZBIbCglkZXZpY2VfaWQYAyABKAlSCGRldmljZUlk');

@$core.Deprecated('Use updateFCMRequestDescriptor instead')
const UpdateFCMRequest$json = {
  '1': 'UpdateFCMRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'fcm_token', '3': 2, '4': 1, '5': 9, '10': 'fcmToken'},
  ],
};

/// Descriptor for `UpdateFCMRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFCMRequestDescriptor = $convert.base64Decode(
    'ChBVcGRhdGVGQ01SZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSGwoJZmNtX3'
    'Rva2VuGAIgASgJUghmY21Ub2tlbg==');

@$core.Deprecated('Use authResponseDescriptor instead')
const AuthResponse$json = {
  '1': 'AuthResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'refresh_token', '3': 2, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.Role', '10': 'role'},
  ],
};

/// Descriptor for `AuthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authResponseDescriptor = $convert.base64Decode(
    'CgxBdXRoUmVzcG9uc2USIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbhIjCg1yZW'
    'ZyZXNoX3Rva2VuGAIgASgJUgxyZWZyZXNoVG9rZW4SFwoHdXNlcl9pZBgDIAEoCVIGdXNlcklk'
    'Eh4KBHJvbGUYBCABKA4yCi5hdXRoLlJvbGVSBHJvbGU=');

@$core.Deprecated('Use refreshRequestDescriptor instead')
const RefreshRequest$json = {
  '1': 'RefreshRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `RefreshRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshRequestDescriptor = $convert.base64Decode(
    'Cg5SZWZyZXNoUmVxdWVzdBIjCg1yZWZyZXNoX3Rva2VuGAEgASgJUgxyZWZyZXNoVG9rZW4SGw'
    'oJZGV2aWNlX2lkGAIgASgJUghkZXZpY2VJZA==');

@$core.Deprecated('Use refreshResponseDescriptor instead')
const RefreshResponse$json = {
  '1': 'RefreshResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'refresh_token', '3': 2, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshResponseDescriptor = $convert.base64Decode(
    'Cg9SZWZyZXNoUmVzcG9uc2USIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbhIjCg'
    '1yZWZyZXNoX3Rva2VuGAIgASgJUgxyZWZyZXNoVG9rZW4=');

@$core.Deprecated('Use logoutRequestDescriptor instead')
const LogoutRequest$json = {
  '1': 'LogoutRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `LogoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutRequestDescriptor = $convert.base64Decode(
    'Cg1Mb2dvdXRSZXF1ZXN0EiMKDXJlZnJlc2hfdG9rZW4YASABKAlSDHJlZnJlc2hUb2tlbg==');
