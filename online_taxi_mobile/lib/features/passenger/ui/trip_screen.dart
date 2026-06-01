import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/trip_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/map_markers.dart';

class PassengerTripScreen extends ConsumerStatefulWidget {
  const PassengerTripScreen({super.key});
  @override
  ConsumerState<PassengerTripScreen> createState() => _PassengerTripScreenState();
}

class _PassengerTripScreenState extends ConsumerState<PassengerTripScreen> {
  YandexMapController? _mapCtrl;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passengerProvider);
    final trip  = state.trip;
    ref.watch(mapMarkersProvider);

    // Когда поездка завершена или отменена — возвращаемся на карту
    ref.listen(passengerProvider, (prev, next) {
      if (prev?.status != PassengerFlowStatus.idle &&
          next.status == PassengerFlowStatus.idle) {
        context.go('/passenger');
      }
    });

    // Двигаем камеру на водителя когда получили его координаты
    if (state.driverLat != null && _mapCtrl != null) {
      _mapCtrl!.moveCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: Point(latitude: state.driverLat!, longitude: state.driverLng!),
          zoom: 15,
        )),
      );
    }

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

    // Маркер водителя — появляется когда начинаем получать его координаты
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

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
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
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: AppTheme.card, shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: const Icon(Icons.person_rounded, color: AppTheme.textSecondary, size: 24),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusLabel, style: const TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          const Text('Toyota Camry • Белый', style: TextStyle(
            color: AppTheme.textSecondary, fontSize: 13)),
        ],
      )),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('A 123 BC', style: TextStyle(
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
