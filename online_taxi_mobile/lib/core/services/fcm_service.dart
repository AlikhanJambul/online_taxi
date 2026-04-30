import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FcmService {
  final _m = FirebaseMessaging.instance;

  Future<bool> requestPermission() async {
    final s = await _m.requestPermission(alert: true, badge: true, sound: true);
    return s.authorizationStatus == AuthorizationStatus.authorized ||
        s.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() => _m.getToken();

  Stream<String>         get onTokenRefresh  => _m.onTokenRefresh;
  Stream<RemoteMessage>  get onForeground    => FirebaseMessaging.onMessage;
  Stream<RemoteMessage>  get onMessageOpened => FirebaseMessaging.onMessageOpenedApp;
  Future<RemoteMessage?> getInitialMessage() => _m.getInitialMessage();
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());
