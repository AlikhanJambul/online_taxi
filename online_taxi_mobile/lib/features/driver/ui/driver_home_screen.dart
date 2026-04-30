import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/driver_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/provider/auth_provider.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider);

    ref.listen(driverProvider, (prev, next) {
      if (next.status == DriverStatus.inTrip) {
        context.push('/driver/trip');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (ctrl) => ctrl.moveCamera(
              CameraUpdate.newCameraPosition(const CameraPosition(
                target: Point(latitude: 51.1605, longitude: 71.4704),
                zoom: 13,
              )),
            ),
            mapObjects: state.lat != null ? [
              PlacemarkMapObject(
                mapId: const MapObjectId('driver'),
                point: Point(latitude: state.lat!, longitude: state.lng!),
                icon: PlacemarkIcon.single(PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage('assets/icons/car.png'),
                )),
              ),
            ] : [],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.local_taxi_rounded, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Водитель', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary, size: 18),
                  ),
                ),
              ]),
            ),
          ),

          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppTheme.border),
              ),
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
                  )),
                  const SizedBox(height: 20),
                  if (state.status == DriverStatus.offline)
                    _OfflineWidget(onGoOnline: () => ref.read(driverProvider.notifier).goOnline()),
                  if (state.status == DriverStatus.online)
                    _OnlineWidget(onGoOffline: () => ref.read(driverProvider.notifier).goOffline()),
                  if (state.status == DriverStatus.hasTrip && state.incomingTrip != null)
                    _IncomingTripWidget(
                      trip: state.incomingTrip!,
                      onAccept: () => ref.read(driverProvider.notifier).acceptTrip(state.incomingTrip!.id),
                      onDecline: () => ref.read(driverProvider.notifier).declineTrip(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineWidget extends StatelessWidget {
  final VoidCallback onGoOnline;
  const _OfflineWidget({required this.onGoOnline});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: AppTheme.card, shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border),
      ),
      child: const Icon(Icons.power_settings_new_rounded, color: AppTheme.textSecondary, size: 28),
    ),
    const SizedBox(height: 14),
    const Text('Вы не в сети', style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    const SizedBox(height: 4),
    const Text('Нажмите кнопку чтобы начать принимать заказы',
      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
    const SizedBox(height: 20),
    ElevatedButton(onPressed: onGoOnline, child: const Text('Выйти на линию')),
  ]);
}

class _OnlineWidget extends StatelessWidget {
  final VoidCallback onGoOffline;
  const _OnlineWidget({required this.onGoOffline});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: AppTheme.online.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.online.withOpacity(0.4), width: 2),
      ),
      child: const Icon(Icons.wifi_rounded, color: AppTheme.online, size: 28),
    ),
    const SizedBox(height: 14),
    const Text('Вы на линии', style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    const SizedBox(height: 4),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
      SizedBox(width: 14, height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
      SizedBox(width: 8),
      Text('Ожидаем заказы...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ]),
    const SizedBox(height: 20),
    OutlinedButton(
      onPressed: onGoOffline,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: AppTheme.textSecondary,
      ),
      child: const Text('Уйти с линии'),
    ),
  ]);
}

class _IncomingTripWidget extends StatelessWidget {
  final IncomingTrip trip;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _IncomingTripWidget({required this.trip, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Новый заказ', style: TextStyle(
          color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
      const Spacer(),
      Text('${trip.priceKzt} ₸', style: const TextStyle(
        color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w700)),
    ]),
    const SizedBox(height: 14),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.radio_button_checked, color: AppTheme.success, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(trip.pickupAddress,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            overflow: TextOverflow.ellipsis)),
          Text('${trip.distanceKm} км',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
        const Padding(padding: EdgeInsets.only(left: 8),
          child: Divider(color: AppTheme.border, height: 16)),
        Row(children: [
          const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(trip.destAddress,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            overflow: TextOverflow.ellipsis)),
        ]),
      ]),
    ),
    const SizedBox(height: 14),
    Row(children: [
      Expanded(child: OutlinedButton(
        onPressed: onDecline,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          side: const BorderSide(color: AppTheme.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: AppTheme.textSecondary,
        ),
        child: const Text('Отказать'),
      )),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton(
        onPressed: onAccept, child: const Text('Принять'),
      )),
    ]),
  ]);
}
