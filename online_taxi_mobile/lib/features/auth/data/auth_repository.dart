import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import '../../../core/grpc/grpc_client.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/services/fcm_service.dart';
import '../../../gen/auth.pb.dart' as pb;
import '../../../gen/auth.pbgrpc.dart';
import '../../../gen/driver.pbenum.dart' as dpbenum;
import '../../../gen/driver.pbgrpc.dart';

enum UserRole { passenger, driver, admin }

enum DriverSetupStatus { unknown, needsSetup, pending, approved, rejected }

class AuthRepository {
  final GrpcClients    _grpc;
  final StorageService _storage;
  final DeviceService  _device;
  final FcmService     _fcm;

  AuthRepository(this._grpc, this._storage, this._device, this._fcm);

  AuthServiceClient get _client =>
      AuthServiceClient(_grpc.auth, interceptors: [_grpc.interceptor]);

  Future<UserRole> register({
    required String   phone,
    required String   password,
    required String   fullName,
    required String   email,
    required UserRole role,
  }) async {
    final deviceId = await _device.getDeviceId();

    final res = await _client.register(pb.RegisterRequest(
      phone:    phone,
      password: password,
      fullName: fullName,
      email:    email,
      deviceId: deviceId,
      role:     role == UserRole.driver ? pb.Role.DRIVER : pb.Role.PASSENGER,
    ));

    await _storage.saveTokens(
      accessToken:  res.accessToken,
      refreshToken: res.refreshToken,
      userId:       res.userId,
      role:         res.role.name,
    );
    await _storage.saveProfile(fullName: fullName, email: email, phone: phone);
    _grpc.interceptor.updateToken(res.accessToken);
    await _sendFcmToken(deviceId);

    return _mapRole(res.role);
  }

  Future<UserRole> login({
    required String email,
    required String password,
  }) async {
    final deviceId = await _device.getDeviceId();

    final res = await _client.login(pb.LoginRequest(
      email:    email,
      password: password,
      deviceId: deviceId,
    ));

    await _storage.saveTokens(
      accessToken:  res.accessToken,
      refreshToken: res.refreshToken,
      userId:       res.userId,
      role:         res.role.name,
    );
    // Обновляем только email — имя и телефон уже в storage с момента регистрации
    final savedName  = await _storage.getFullName() ?? '';
    final savedPhone = await _storage.getPhone()    ?? '';
    await _storage.saveProfile(fullName: savedName, email: email, phone: savedPhone);
    _grpc.interceptor.updateToken(res.accessToken);
    await _sendFcmToken(deviceId);

    return _mapRole(res.role);
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _client.logout(pb.LogoutRequest(refreshToken: refreshToken));
      } catch (_) {
        // Токен уже протух — ничего страшного, чистим локально
      }
    }
    _grpc.interceptor.updateToken(null);
    await _storage.clear();
  }

  Future<UserRole?> getSavedRole() async {
    final r = await _storage.getRole();
    return r != null ? _parseRoleString(r) : null;
  }

  Future<void> _sendFcmToken(String deviceId) async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _client.updateFCMToken(pb.UpdateFCMRequest(
        deviceId: deviceId,
        fcmToken: token,
      ));
    } catch (_) {
      // FCM не критичен для входа
    }
  }

  UserRole _mapRole(pb.Role r) {
    switch (r) {
      case pb.Role.DRIVER: return UserRole.driver;
      case pb.Role.ADMIN:  return UserRole.admin;
      default:             return UserRole.passenger;
    }
  }

  Future<({String uploadUrl, String fileUrl})> getAvatarUploadUrl() async {
    final res = await _client.getAvatarsUploadURL(Empty());
    return (uploadUrl: res.uploadUrl, fileUrl: res.fileUrl);
  }

  Future<String?> getSavedName()      => _storage.getFullName();
  Future<String?> getSavedEmail()     => _storage.getEmail();
  Future<String?> getSavedPhone()     => _storage.getPhone();
  Future<String?> getSavedAvatarUrl() => _storage.getAvatarUrl();

  Future<DriverSetupStatus> checkDriverSetupStatus() async {
    try {
      final driverClient = DriverServiceClient(_grpc.driver, interceptors: [_grpc.interceptor]);
      final profile = await driverClient.getProfile(Empty());
      switch (profile.status) {
        case dpbenum.DriverStatus.PENDING:  return DriverSetupStatus.pending;
        case dpbenum.DriverStatus.APPROVED: return DriverSetupStatus.approved;
        case dpbenum.DriverStatus.REJECTED: return DriverSetupStatus.rejected;
        default:                            return DriverSetupStatus.needsSetup;
      }
    } catch (_) {
      return DriverSetupStatus.needsSetup;
    }
  }

  UserRole _parseRoleString(String r) {
    switch (r.toLowerCase()) {
      case 'driver': return UserRole.driver;
      case 'admin':  return UserRole.admin;
      default:       return UserRole.passenger;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(
  ref.watch(grpcClientsProvider),
  ref.watch(storageServiceProvider),
  ref.watch(deviceServiceProvider),
  ref.watch(fcmServiceProvider),
));
