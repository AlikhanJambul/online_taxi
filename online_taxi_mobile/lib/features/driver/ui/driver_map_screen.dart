import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/driver_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/map_markers.dart';

class DriverMapScreen extends ConsumerStatefulWidget {
  const DriverMapScreen({super.key});
  @override
  ConsumerState<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends ConsumerState<DriverMapScreen> {
  YandexMapController? _mapCtrl;
  bool _following = true; // автоследование за водителем

  static const _defaultPos = Point(latitude: 51.1605, longitude: 71.4704);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      _moveCamera(pos.latitude, pos.longitude, zoom: 15);
    } catch (_) {}
  }

  void _moveCamera(double lat, double lng, {double zoom = 15}) {
    _mapCtrl?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: Point(latitude: lat, longitude: lng), zoom: zoom),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.6),
    );
  }

  void _centerOnDriver() {
    final state = ref.read(driverProvider);
    if (state.lat != null) {
      setState(() => _following = true);
      _moveCamera(state.lat!, state.lng!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(driverProvider);
    final markers = ref.watch(mapMarkersProvider).valueOrNull;

    // Следим за изменением координат водителя
    ref.listen<DriverState>(driverProvider, (prev, next) {
      if (next.status == DriverStatus.enRoute &&
          prev?.status != DriverStatus.enRoute) {
        context.push('/driver/trip');
        return;
      }
      // Двигаем камеру только если включено автоследование
      if (_following && next.lat != null &&
          (next.lat != prev?.lat || next.lng != prev?.lng)) {
        _moveCamera(next.lat!, next.lng!);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (ctrl) {
              _mapCtrl = ctrl;
              ctrl.moveCamera(CameraUpdate.newCameraPosition(
                const CameraPosition(target: _defaultPos, zoom: 13),
              ));
            },
            // Если пользователь вручную двигает карту — отключаем автоследование
            onCameraPositionChanged: (_, reason, __) {
              if (reason == CameraUpdateReason.gestures && _following) {
                setState(() => _following = false);
              }
            },
            mapObjects: state.lat != null && markers != null
                ? [
                    PlacemarkMapObject(
                      mapId: const MapObjectId('driver'),
                      point: Point(latitude: state.lat!, longitude: state.lng!),
                      icon: PlacemarkIcon.single(PlacemarkIconStyle(
                        image: BitmapDescriptor.fromBytes(markers.car),
                        scale: 1.5,
                      )),
                    ),
                  ]
                : [],
          ),

          // Шапка
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppTheme.textPrimary, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Принять заказы', style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                )),
                const Spacer(),
                // Кнопка «вернуться к себе»
                GestureDetector(
                  onTap: _centerOnDriver,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _following ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _following ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                    child: Icon(
                      Icons.my_location_rounded,
                      color: _following ? AppTheme.primary : AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // Нижняя панель
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppTheme.border),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve:  Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.12),
                          end:   Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _panelContent(context, state, ref),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelContent(BuildContext context, DriverState state, WidgetRef ref) {
    switch (state.status) {
      case DriverStatus.online:
        return _OnlineWidget(
          key: const ValueKey('online'),
          onGoOffline: () => ref.read(driverProvider.notifier).goOffline(),
        );
      case DriverStatus.hasTrip when state.incomingTrip != null:
        return _IncomingTripWidget(
          key: ValueKey('trip_${state.incomingTrip!.id}'),
          trip:      state.incomingTrip!,
          onAccept:  () => ref.read(driverProvider.notifier).acceptTrip(state.incomingTrip!.id),
          onDecline: () => ref.read(driverProvider.notifier).declineTrip(),
        );
      case DriverStatus.enRoute:
      case DriverStatus.arrived:
      case DriverStatus.inTrip:
        return _InTripWidget(
          key: const ValueKey('inTrip'),
          onOpenTrip: () => context.push('/driver/trip'),
        );
      default:
        return _OfflineWidget(
          key: const ValueKey('offline'),
          onGoOnline: () {
            setState(() => _following = true);
            ref.read(driverProvider.notifier).goOnline();
          },
        );
    }
  }
}

// ── Offline ───────────────────────────────────────────────────────────────────

class _OfflineWidget extends StatelessWidget {
  final VoidCallback onGoOnline;
  const _OfflineWidget({super.key, required this.onGoOnline});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: AppTheme.card, shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border),
      ),
      child: const Icon(Icons.power_settings_new_rounded,
          color: AppTheme.textSecondary, size: 28),
    ),
    const SizedBox(height: 14),
    const Text('Вы не в сети', style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    const SizedBox(height: 4),
    const Text('Нажмите кнопку чтобы начать принимать заказы',
      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      textAlign: TextAlign.center),
    const SizedBox(height: 20),
    ElevatedButton(onPressed: onGoOnline, child: const Text('Выйти на линию')),
  ]);
}

// ── Online ────────────────────────────────────────────────────────────────────

class _OnlineWidget extends StatelessWidget {
  final VoidCallback onGoOffline;
  const _OnlineWidget({super.key, required this.onGoOffline});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: AppTheme.online.withValues(alpha: 0.15), shape: BoxShape.circle,
        border: Border.all(color: AppTheme.online.withValues(alpha: 0.4), width: 2),
      ),
      child: const Icon(Icons.wifi_rounded, color: AppTheme.online, size: 28),
    ),
    const SizedBox(height: 14),
    const Text('Вы на линии', style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    const SizedBox(height: 4),
    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 14, height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
      SizedBox(width: 8),
      Text('Ожидаем заказы...',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
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

// ── In trip ───────────────────────────────────────────────────────────────────

class _InTripWidget extends StatelessWidget {
  final VoidCallback onOpenTrip;
  const _InTripWidget({super.key, required this.onOpenTrip});

  @override
  Widget build(BuildContext context) => Column(children: [
    const Icon(Icons.directions_car_rounded, color: AppTheme.primary, size: 36),
    const SizedBox(height: 12),
    const Text('Вы в поездке', style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    const SizedBox(height: 20),
    ElevatedButton(onPressed: onOpenTrip, child: const Text('Вернуться к поездке')),
  ]);
}

// ── Incoming trip ─────────────────────────────────────────────────────────────

class _IncomingTripWidget extends StatelessWidget {
  final IncomingTrip trip;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _IncomingTripWidget({
    super.key,
    required this.trip,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Новый заказ', style: TextStyle(
          color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
      const Spacer(),
      Text('${trip.priceKzt} ₸', style: const TextStyle(
        color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w700)),
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
          Text('${trip.distanceKm.toStringAsFixed(1)} км',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
        const Padding(
          padding: EdgeInsets.only(left: 8),
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
        onPressed: onAccept,
        child: const Text('Принять'),
      )),
    ]),
  ]);
}
