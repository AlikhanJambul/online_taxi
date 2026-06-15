import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'features/driver/provider/driver_provider.dart';
import 'features/passenger/provider/trip_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: TaxiApp()));
}

class TaxiApp extends ConsumerStatefulWidget {
  const TaxiApp({super.key});
  @override
  ConsumerState<TaxiApp> createState() => _TaxiAppState();
}

class _TaxiAppState extends ConsumerState<TaxiApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupFcm());
  }

  void _setupFcm() {
    final fcm = ref.read(fcmServiceProvider);
    fcm.requestPermission();
    fcm.onForeground.listen(_handleMessage);
    fcm.onMessageOpened.listen(_handleMessage);
    fcm.getInitialMessage().then((m) { if (m != null) _handleMessage(m); });
  }

  void _handleMessage(RemoteMessage msg) {
    final data = msg.data;
    final type = data['type'];

    if (type == 'new_trip') {
      final trip = IncomingTrip(
        id:            data['trip_id']     ?? '',
        pickupAddress: data['pickup_address'] ?? '',
        destAddress:   data['dest_address']   ?? '',
        pickupLat:     double.tryParse(data['pickup_lat']  ?? '') ?? 0,
        pickupLng:     double.tryParse(data['pickup_lng']  ?? '') ?? 0,
        destLat:       double.tryParse(data['dest_lat']    ?? '') ?? 0,
        destLng:       double.tryParse(data['dest_lng']    ?? '') ?? 0,
        priceKzt:      int.tryParse   (data['price_kzt']   ?? '') ?? 0,
        distanceKm:    double.tryParse(data['distance_km'] ?? '') ?? 0,
      );
      ref.read(driverProvider.notifier).notifyIncomingTrip(trip);

    } else if (type == 'status_changed') {
      final tripId = data['trip_id'] ?? '';
      final status = data['status']  ?? '';
      ref.read(passengerProvider.notifier).updateTripStatus(tripId, status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Такси',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
