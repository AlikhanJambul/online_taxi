import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/trip_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/map_markers.dart';
import '../../../core/widgets/user_avatar.dart';

// Расстояние между двумя точками на сфере (метры)
double _distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLng = (lng2 - lng1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

class PassengerTripScreen extends ConsumerStatefulWidget {
  const PassengerTripScreen({super.key});
  @override
  ConsumerState<PassengerTripScreen> createState() => _PassengerTripScreenState();
}

class _PassengerTripScreenState extends ConsumerState<PassengerTripScreen> {
  YandexMapController? _mapCtrl;
  List<Point>? _routeToPickup;
  List<Point>? _routeToDest;
  double? _lastCameraLat, _lastCameraLng;
  double? _lastRouteLat,  _lastRouteLng;

  Future<void> _calculateRoute({
    required Point from,
    required Point to,
    required bool toPickup,
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
          if (toPickup) {
            _routeToPickup = result.routes!.first.geometry;
          } else {
            _routeToDest = result.routes!.first.geometry;
          }
        });
      }
    } catch (e) {
      debugPrint('Route calculation failed: $e');
    }
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ReviewSheet(
        onSubmit: (score) {
          Navigator.of(context).pop();
          ref.read(passengerProvider.notifier).submitReview(score);
        },
        onSkip: () {
          Navigator.of(context).pop();
          ref.read(passengerProvider.notifier).dismissReview();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passengerProvider);
    final trip  = state.trip;
    ref.watch(mapMarkersProvider);

    ref.listen(passengerProvider, (prev, next) {
      final prevStatus = prev?.trip?.status;
      final nextStatus = next.trip?.status;

      // Следим за водителем камерой только когда он реально сдвинулся,
      // чтобы карта не "перерисовывалась" целиком на каждое обновление позиции
      if (next.driverLat != null &&
          (_lastCameraLat == null ||
           _distanceMeters(_lastCameraLat!, _lastCameraLng!, next.driverLat!, next.driverLng!) > 15)) {
        _lastCameraLat = next.driverLat;
        _lastCameraLng = next.driverLng;
        _mapCtrl?.moveCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
            target: Point(latitude: next.driverLat!, longitude: next.driverLng!),
            zoom: 15,
          )),
          animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
        );
      }

      // Маршрут водитель → посадка: считаем при первом получении локации водителя
      // и пересчитываем по мере его движения к точке А
      if (nextStatus == TripStatus.accepted &&
          next.driverLat != null &&
          next.pickupLat != null &&
          (_lastRouteLat == null ||
           _distanceMeters(_lastRouteLat!, _lastRouteLng!, next.driverLat!, next.driverLng!) > 30)) {
        _lastRouteLat = next.driverLat;
        _lastRouteLng = next.driverLng;
        _calculateRoute(
          from:     Point(latitude: next.driverLat!,  longitude: next.driverLng!),
          to:       Point(latitude: next.pickupLat!,  longitude: next.pickupLng!),
          toPickup: true,
        );
      }

      // Маршрут посадка → назначение (поездка началась)
      if (nextStatus == TripStatus.inProgress &&
          prevStatus != TripStatus.inProgress &&
          next.pickupLat != null &&
          next.destLat != null) {
        setState(() => _routeToPickup = null);
        _calculateRoute(
          from:     Point(latitude: next.pickupLat!, longitude: next.pickupLng!),
          to:       Point(latitude: next.destLat!,   longitude: next.destLng!),
          toPickup: false,
        );
      }

      // Очищаем маршруты при завершении/отмене
      if (nextStatus == TripStatus.completed || nextStatus == TripStatus.cancelled) {
        setState(() { _routeToPickup = null; _routeToDest = null; });
      }

      // Показываем диалог отзыва после завершения поездки
      if (!prev!.pendingReview && next.pendingReview) {
        _showReviewDialog(context, ref);
        return;
      }
      // Отзыв отправлен или пропущен — возвращаемся на главную
      if (prev.pendingReview && !next.pendingReview) {
        context.go('/passenger');
        return;
      }
      // Таймаут поиска или другая ошибка
      if (next.status == PassengerFlowStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ));
        context.go('/passenger');
        return;
      }
      // Поездка отменена — на главную
      if (prev.status != PassengerFlowStatus.idle &&
          next.status == PassengerFlowStatus.idle &&
          !next.pendingReview) {
        context.go('/passenger');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (ctrl) {
              _mapCtrl = ctrl;
              if (trip != null) {
                ctrl.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: Point(latitude: trip.pickupLat, longitude: trip.pickupLng),
                  zoom: 14,
                )));
              }
            },
            mapObjects: _buildMapObjects(state),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
                        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
                child: _StatusBadge(
                  key: ValueKey('${state.status}_${trip?.status}'),
                  trip: trip, flowStatus: state.status,
                ),
              ),
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
                  if (state.status == PassengerFlowStatus.searching)
                    _SearchingWidget(onCancel: () {
                      ref.read(passengerProvider.notifier).cancelSearch();
                      context.pop();
                    }),
                  if (state.status == PassengerFlowStatus.active && trip != null)
                    _ActiveTripWidget(trip: trip),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MapObject> _buildMapObjects(PassengerState state) {
    final objects = <MapObject>[];
    final m       = ref.read(mapMarkersProvider).valueOrNull;
    final status  = state.trip?.status;

    // Маршрут водитель → посадка (реальный по дорогам, синий)
    if (_routeToPickup != null && status == TripStatus.accepted) {
      objects.add(PolylineMapObject(
        mapId: const MapObjectId('route_to_pickup'),
        polyline: Polyline(points: _routeToPickup!),
        strokeColor: const Color(0xFF1976D2),
        strokeWidth: 4.0,
        outlineColor: Colors.white,
        outlineWidth: 1.5,
      ));
    }

    // Маршрут посадка → назначение (реальный по дорогам, зелёный)
    if (_routeToDest != null && status == TripStatus.inProgress) {
      objects.add(PolylineMapObject(
        mapId: const MapObjectId('route_to_dest'),
        polyline: Polyline(points: _routeToDest!),
        strokeColor: const Color(0xFF2E7D32),
        strokeWidth: 4.0,
        outlineColor: Colors.white,
        outlineWidth: 1.5,
      ));
    }

    if (state.pickupLat != null && m != null) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('pickup'),
        point: Point(latitude: state.pickupLat!, longitude: state.pickupLng!),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(image: BitmapDescriptor.fromBytes(m.pickup))),
      ));
    }

    if (state.destLat != null && m != null) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('dest'),
        point: Point(latitude: state.destLat!, longitude: state.destLng!),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(image: BitmapDescriptor.fromBytes(m.destination))),
      ));
    }

    if (state.driverLat != null && m != null) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('driver'),
        point: Point(latitude: state.driverLat!, longitude: state.driverLng!),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(image: BitmapDescriptor.fromBytes(m.car))),
      ));
    }

    return objects;
  }
}

class _StatusBadge extends StatelessWidget {
  final Trip?                trip;
  final PassengerFlowStatus  flowStatus;
  const _StatusBadge({super.key, required this.trip, required this.flowStatus});

  @override
  Widget build(BuildContext context) {
    String label;
    bool   loading = false;
    Color  iconColor = AppTheme.primary;

    if (flowStatus == PassengerFlowStatus.searching) {
      label   = 'Ищем водителя...';
      loading = true;
    } else {
      switch (trip?.status) {
        case TripStatus.accepted:   label = 'Водитель едет к вам'; break;
        case TripStatus.arrived:    label = 'Водитель ждёт вас'; iconColor = AppTheme.success; break;
        case TripStatus.inProgress: label = 'Поездка началась'; break;
        default:                    return const SizedBox.shrink();
      }
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (loading)
            const SizedBox(width: 12, height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
          else
            Icon(Icons.directions_car_rounded, color: iconColor, size: 14),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(
            color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _SearchingWidget extends StatelessWidget {
  final VoidCallback onCancel;
  const _SearchingWidget({required this.onCancel});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
      ),
      child: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 28),
    ),
    const SizedBox(height: 16),
    const Text('Ищем водителя рядом', style: TextStyle(
      fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    const SizedBox(height: 6),
    const Text('Обычно занимает 1–3 минуты',
      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    const SizedBox(height: 24),
    OutlinedButton(
      onPressed: onCancel,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: AppTheme.textSecondary,
      ),
      child: const Text('Отменить'),
    ),
  ]);
}

class _ActiveTripWidget extends StatelessWidget {
  final Trip trip;
  const _ActiveTripWidget({required this.trip});

  String get _statusLabel {
    switch (trip.status) {
      case TripStatus.accepted:   return 'Водитель назначен';
      case TripStatus.arrived:    return 'Водитель на месте';
      case TripStatus.inProgress: return 'Поездка идёт';
      default:                    return 'Водитель назначен';
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      UserAvatar(avatarUrl: trip.driverAvatarUrl, size: 48),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusLabel, style: const TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            [trip.carMake, trip.carModel, trip.carColor]
                .where((s) => s.isNotEmpty).join(' · '),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      )),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          trip.licensePlate.isNotEmpty ? trip.licensePlate : '—',
          style: const TextStyle(
            color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    ]),
    const SizedBox(height: 20),
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
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Стоимость', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
      Text('${trip.priceKzt} ₸', style: const TextStyle(
        color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w700)),
    ]),
  ]);
}

// ── Диалог отзыва ─────────────────────────────────────────────────────────────

class _ReviewSheet extends StatefulWidget {
  final void Function(int score) onSubmit;
  final VoidCallback              onSkip;
  const _ReviewSheet({required this.onSubmit, required this.onSkip});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _score = 0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
        24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: AppTheme.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Оцените поездку',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          )),
        const SizedBox(height: 6),
        const Text('Как вам водитель?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _score = star),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  _score >= star ? Icons.star_rounded : Icons.star_border_rounded,
                  color: _score >= star ? AppTheme.primary : AppTheme.textSecondary,
                  size: 44,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _score > 0 ? () => widget.onSubmit(_score) : null,
          child: const Text('Отправить'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: widget.onSkip,
          child: const Text('Пропустить',
            style: TextStyle(color: AppTheme.textSecondary)),
        ),
      ],
    ),
  );
}
