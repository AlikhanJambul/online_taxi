import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _s = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
  }) async {
    await Future.wait([
      _s.write(key: 'access_token',  value: accessToken),
      _s.write(key: 'refresh_token', value: refreshToken),
      _s.write(key: 'user_id',       value: userId),
      _s.write(key: 'role',          value: role),
    ]);
  }

  Future<String?> getAccessToken()  => _s.read(key: 'access_token');
  Future<String?> getRefreshToken() => _s.read(key: 'refresh_token');
  Future<String?> getUserId()       => _s.read(key: 'user_id');
  Future<String?> getRole()         => _s.read(key: 'role');

  Future<void> saveDeviceId(String id) => _s.write(key: 'device_id', value: id);
  Future<String?> getDeviceId()        => _s.read(key: 'device_id');

  Future<bool> isLoggedIn() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> clear() => _s.deleteAll();
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
