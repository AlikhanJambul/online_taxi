import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/grpc/grpc_client.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/services/fcm_service.dart';

// TODO: когда сгенеришь proto файлы раскомментируй:
// import '../../../gen/auth.pbgrpc.dart';

enum UserRole { passenger, driver, admin }

class AuthRepository {
  final GrpcClients   _grpc;
  final StorageService _storage;
  final DeviceService  _device;
  final FcmService     _fcm;

  AuthRepository(this._grpc, this._storage, this._device, this._fcm);

  Future<UserRole> register({
    required String phone,
    required String password,
    required String fullName,
    required String email,
    required UserRole role,
  }) async {
    // TODO: раскомментируй после генерации proto
    // final deviceId = await _device.getDeviceId();
    // final client = AuthServiceClient(_grpc.auth, interceptors: [_grpc.interceptor]);
    // final res = await client.register(RegisterRequest(
    //   phone: phone, password: password, fullName: fullName,
    //   email: email, deviceId: deviceId,
    //   role: role == UserRole.driver ? Role.DRIVER : Role.PASSENGER,
    // ));
    // await _storage.saveTokens(
    //   accessToken: res.accessToken, refreshToken: res.refreshToken,
    //   userId: res.userId, role: res.role.name,
    // );
    // _grpc.interceptor.updateToken(res.accessToken);
    // await _sendFcmToken(client, deviceId);
    // return _parseRole(res.role.name);

    await Future.delayed(const Duration(milliseconds: 800));
    await _storage.saveTokens(
      accessToken: 'mock_access', refreshToken: 'mock_refresh',
      userId: 'mock_user_id', role: role.name,
    );
    _grpc.interceptor.updateToken('mock_access');
    return role;
  }

  Future<UserRole> login({
    required String email,
    required String password,
  }) async {
    // TODO: раскомментируй после генерации proto
    // final deviceId = await _device.getDeviceId();
    // final client = AuthServiceClient(_grpc.auth, interceptors: [_grpc.interceptor]);
    // final res = await client.login(LoginRequest(
    //   email: email, password: password, deviceId: deviceId,
    // ));
    // await _storage.saveTokens(
    //   accessToken: res.accessToken, refreshToken: res.refreshToken,
    //   userId: res.userId, role: res.role.name,
    // );
    // _grpc.interceptor.updateToken(res.accessToken);
    // await _sendFcmToken(client, deviceId);
    // return _parseRole(res.role.name);

    await Future.delayed(const Duration(milliseconds: 800));
    final role = email.contains('driver') ? UserRole.driver : UserRole.passenger;
    await _storage.saveTokens(
      accessToken: 'mock_access', refreshToken: 'mock_refresh',
      userId: 'mock_user_id', role: role.name,
    );
    _grpc.interceptor.updateToken('mock_access');
    return role;
  }

  Future<void> logout() async {
    // TODO: await client.logout(LogoutRequest(refreshToken: ...));
    _grpc.interceptor.updateToken(null);
    await _storage.clear();
  }

  Future<UserRole?> getSavedRole() async {
    final r = await _storage.getRole();
    return r != null ? _parseRole(r) : null;
  }

  // Future<void> _sendFcmToken(AuthServiceClient client, String deviceId) async {
  //   final token = await _fcm.getToken();
  //   if (token == null) return;
  //   await client.updateFCMToken(UpdateFCMRequest(deviceId: deviceId, fcmToken: token));
  // }

  UserRole _parseRole(String r) {
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
