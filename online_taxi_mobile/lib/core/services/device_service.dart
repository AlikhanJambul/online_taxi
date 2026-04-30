import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'storage_service.dart';

class DeviceService {
  final StorageService _storage;
  DeviceService(this._storage);

  Future<String> getDeviceId() async {
    final saved = await _storage.getDeviceId();
    if (saved != null && saved.isNotEmpty) return saved;

    String id;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        id = (await info.androidInfo).id;
      } else if (Platform.isIOS) {
        id = (await info.iosInfo).identifierForVendor ?? const Uuid().v4();
      } else {
        id = const Uuid().v4();
      }
    } catch (_) {
      id = const Uuid().v4();
    }

    await _storage.saveDeviceId(id);
    return id;
  }
}

final deviceServiceProvider = Provider<DeviceService>(
  (ref) => DeviceService(ref.watch(storageServiceProvider)),
);
