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

  Future<void> saveProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    await Future.wait([
      _s.write(key: 'full_name', value: fullName),
      _s.write(key: 'email',     value: email),
      _s.write(key: 'phone',     value: phone),
    ]);
  }

  Future<String?> getAccessToken()  => _s.read(key: 'access_token');
  Future<String?> getRefreshToken() => _s.read(key: 'refresh_token');
  Future<String?> getUserId()       => _s.read(key: 'user_id');
  Future<String?> getRole()         => _s.read(key: 'role');
  Future<String?> getFullName()     => _s.read(key: 'full_name');
  Future<String?> getEmail()        => _s.read(key: 'email');
  Future<String?> getPhone()        => _s.read(key: 'phone');
  Future<String?> getAvatarUrl()    => _s.read(key: 'avatar_url');
  Future<void>    saveAvatarUrl(String url) => _s.write(key: 'avatar_url', value: url);

  Future<void> saveDeviceId(String id) => _s.write(key: 'device_id', value: id);
  Future<String?> getDeviceId()        => _s.read(key: 'device_id');

  Future<bool> isLoggedIn() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> clear() => Future.wait([
    _s.delete(key: 'access_token'),
    _s.delete(key: 'refresh_token'),
    _s.delete(key: 'user_id'),
    _s.delete(key: 'role'),
  ]);
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
