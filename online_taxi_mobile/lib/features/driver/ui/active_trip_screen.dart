import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/driver_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/map_markers.dart';

class DriverActiveTripScreen extends ConsumerStatefulWidget {
  const DriverActiveTripScreen({super.key});

  @override
  ConsumerState<DriverActiveTripScreen> createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends ConsumerState<DriverActiveTripScreen> {
  YandexMapController? _mapCtrl;
  List<Point>? _route;
  DriverStatus? _routeForStatus;

  Future<void> _calculateRoute({
    required Point from,
    required Point to,
    required DriverStatus forStatus,
  }) async {
    try {
      final resultWithSession = await YandexDriving.requestRoutes(
        points: [
          RequestPoint(point: from, requestPointType: RequestPointType.wayPoint),
          RequestPoint(point: to,   requestPointType: RequestPointType.wayPoint),
        ],
        drivingOptions: const DrivingOptions(routesCount: 1),
      );
      final result = await resultWithSession.result;
      if (!mounted) return;
      if (result.routes != null && result.routes!.isNotEmpty) {
        setState(() {
          _route = result.routes!.first.geometry;
          _routeForStatus = forStatus;
        });
      }
    } catch (e) {
      debugPrint('[Route] ошибка расчёта маршрута: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(driverProvider);
    final markers = ref.watch(mapMarkersProvider).valueOrNull;
    final trip    = state.activeTrip;

    // Центрируем карту когда приходят координаты
    ref.listen(driverProvider, (prev, next) {
      if (next.lat != null && next.lng != null &&
          (next.lat != prev?.lat || next.lng != prev?.lng)) {
        _mapCtrl?.moveCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
            target: Point(latitude: next.lat!, longitude: next.lng!),
            zoom: 15,
          )),
          animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
        );
      }

      // Маршрут до пассажира — пока едем к месту посадки
      if (next.status == DriverStatus.enRoute &&
          next.lat != null && next.activeTrip != null &&
          _routeForStatus != DriverStatus.enRoute) {
        _calculateRoute(
          from: Point(latitude: next.lat!, longitude: next.lng!),
          to:   Point(latitude: next.activeTrip!.pickupLat, longitude: next.activeTrip!.pickupLng),
          forStatus: DriverStatus.enRoute,
        );
      }

      // Маршрут до точки назначения — после начала поездки
      if (next.status == DriverStatus.inTrip &&
          prev?.status != DriverStatus.inTrip &&
          next.lat != null && next.activeTrip != null) {
        setState(() => _route = null);
        _calculateRoute(
          from: Point(latitude: next.lat!, longitude: next.lng!),
          to:   Point(latitude: next.activeTrip!.destLat, longitude: next.activeTrip!.destLng),
          forStatus: DriverStatus.inTrip,
        );
      }

      // Когда поездка завершена — возвращаемся на главный экран
      if (next.status == DriverStatus.online && prev?.status == DriverStatus.inTrip) {
        context.pop();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Карта ──────────────────────────────────────────────────────────
          YandexMap(
            onMapCreated: (ctrl) {
              _mapCtrl = ctrl;
              if (state.lat != null && state.lng != null) {
                ctrl.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: Point(latitude: state.lat!, longitude: state.lng!),
                  zoom: 15,
                )));
              }
            },
            mapObjects: _buildMapObjects(state, markers, trip),
          ),

          // ── Статусный чип сверху ───────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: _StatusChip(status: state.status),
              ),
            ),
          ),

          // ── Нижняя панель ─────────────────────────────────────────────────
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
                      color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
                  )),
                  const SizedBox(height: 20),

                  // Инфо о маршруте
                  if (trip != null) ...[
                    _RouteCard(trip: trip),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Оплата',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        Text('${trip.priceKzt} ₸',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Кнопки в зависимости от статуса
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: _ActionButton(
                      key: ValueKey(state.status),
                      status: state.status,
                      onArrived:  () => ref.read(driverProvider.notifier).markArrived(),
                      onStart:    () => ref.read(driverProvider.notifier).startDriving(),
                      onComplete: () => ref.read(driverProvider.notifier).completeTrip(),
                      onCancel:   () {
                        ref.read(driverProvider.notifier).cancelCurrentTrip();
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MapObject> _buildMapObjects(DriverState state, MapMarkers? markers, IncomingTrip? trip) {
    final objects = <MapObject>[];
    if (markers == null) return objects;

    if (_route != null &&
        ((_routeForStatus == DriverStatus.enRoute && state.status == DriverStatus.enRoute) ||
         (_routeForStatus == DriverStatus.inTrip  && state.status == DriverStatus.inTrip))) {
      objects.add(PolylineMapObject(
        mapId: const MapObjectId('route'),
        polyline: Polyline(points: _route!),
        strokeColor: const Color(0xFF1976D2),
        strokeWidth: 4.0,
        outlineColor: Colors.white,
        outlineWidth: 1.5,
      ));
    }

    if (trip != null && state.status == DriverStatus.enRoute) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('pickup'),
        point: Point(latitude: trip.pickupLat, longitude: trip.pickupLng),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(markers.pickup),
        )),
      ));
    }

    if (trip != null &&
        (state.status == DriverStatus.arrived || state.status == DriverStatus.inTrip)) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('dest'),
        point: Point(latitude: trip.destLat, longitude: trip.destLng),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(markers.destination),
        )),
      ));
    }

    if (state.lat != null && state.lng != null) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('driver'),
        point: Point(latitude: state.lat!, longitude: state.lng!),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(markers.car),
        )),
      ));
    }

    return objects;
  }
}

// ── Статусный чип ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final DriverStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (status) {
      DriverStatus.enRoute => (Icons.directions_car_rounded,  'Еду к пассажиру', AppTheme.primary),
      DriverStatus.arrived => (Icons.person_pin_circle_rounded,'Жду пассажира',   AppTheme.success),
      DriverStatus.inTrip  => (Icons.flag_rounded,             'Поездка идёт',    AppTheme.primary),
      _                    => (Icons.directions_car_rounded,  'В поездке',        AppTheme.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ── Карточка маршрута ─────────────────────────────────────────────────────────

class _RouteCard extends StatelessWidget {
  final IncomingTrip trip;
  const _RouteCard({required this.trip});

  @override
  Widget build(BuildContext context) => Container(
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
      ]),
      const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Divider(color: AppTheme.border, height: 16),
      ),
      Row(children: [
        const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(trip.destAddress,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            overflow: TextOverflow.ellipsis)),
      ]),
    ]),
  );
}

// ── Кнопка действия ───────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final DriverStatus status;
  final VoidCallback onArrived;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _ActionButton({
    super.key,
    required this.status,
    required this.onArrived,
    required this.onStart,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      DriverStatus.enRoute => Column(mainAxisSize: MainAxisSize.min, children: [
          _primaryBtn('Я приехал', Icons.location_on_rounded, onArrived),
          const SizedBox(height: 10),
          _cancelBtn(onCancel),
        ]),
      DriverStatus.arrived => Column(mainAxisSize: MainAxisSize.min, children: [
          _primaryBtn('Начать поездку', Icons.play_arrow_rounded, onStart),
          const SizedBox(height: 10),
          _cancelBtn(onCancel),
        ]),
      DriverStatus.inTrip => _primaryBtn('Завершить поездку', Icons.flag_rounded, onComplete),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _primaryBtn(String label, IconData icon, VoidCallback onTap) =>
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  Widget _cancelBtn(VoidCallback onTap) =>
      SizedBox(
        width: double.infinity,
        height: 46,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.border),
            foregroundColor: AppTheme.textSecondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Отменить поездку'),
        ),
      );
}
