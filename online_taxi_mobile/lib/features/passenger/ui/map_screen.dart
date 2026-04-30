import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/trip_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/provider/auth_provider.dart';

class PassengerMapScreen extends ConsumerStatefulWidget {
  const PassengerMapScreen({super.key});
  @override
  ConsumerState<PassengerMapScreen> createState() => _PassengerMapScreenState();
}

class _PassengerMapScreenState extends ConsumerState<PassengerMapScreen> {
  YandexMapController? _mapCtrl;
  final _destCtrl   = TextEditingController();
  final _pickupCtrl = TextEditingController();

  static const _defaultPos = Point(latitude: 51.1605, longitude: 71.4704);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    _pickupCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      _mapCtrl?.moveCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: Point(latitude: pos.latitude, longitude: pos.longitude),
          zoom: 14,
        )),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
      );
      ref.read(passengerProvider.notifier).setPickup(
        address: 'Моё местоположение',
        lat: pos.latitude,
        lng: pos.longitude,
      );
      _pickupCtrl.text = 'Моё местоположение';
    } catch (_) {}
  }

  void _onDestSet() {
    final dest = _destCtrl.text.trim();
    if (dest.isEmpty) return;
    ref.read(passengerProvider.notifier).setDest(
      address: dest,
      lat: 51.1505,
      lng: 71.4604,
    );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passengerProvider);

    ref.listen(passengerProvider, (prev, next) {
      if (next.status == PassengerFlowStatus.searching ||
          next.status == PassengerFlowStatus.active) {
        context.push('/passenger/trip');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (ctrl) {
              _mapCtrl = ctrl;
              ctrl.moveCamera(CameraUpdate.newCameraPosition(
                const CameraPosition(target: _defaultPos, zoom: 12),
              ));
            },
            mapObjects: _buildMapObjects(state),
          ),

          // Шапка
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
                const Text('Такси', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
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

          // Нижняя панель
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
                  )),
                  const SizedBox(height: 16),
                  const Text('Куда едем?', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 14),

                  _AddressField(controller: _pickupCtrl, hint: 'Откуда',
                    icon: Icons.radio_button_checked, iconColor: AppTheme.success, readOnly: true),
                  const SizedBox(height: 8),
                  _AddressField(controller: _destCtrl, hint: 'Куда',
                    icon: Icons.location_on_rounded, iconColor: AppTheme.primary,
                    onSubmitted: (_) => _onDestSet()),

                  if (state.status == PassengerFlowStatus.estimating) ...[
                    const SizedBox(height: 16),
                    const Center(child: _PriceLoading()),
                  ],
                  if (state.estimate != null && state.status == PassengerFlowStatus.estimated) ...[
                    const SizedBox(height: 16),
                    _PriceCard(estimate: state.estimate!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(passengerProvider.notifier).createTrip(),
                      child: const Text('Заказать'),
                    ),
                  ],
                  if (state.status == PassengerFlowStatus.creating) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: null,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                        SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                        SizedBox(width: 10),
                        Text('Создаём поездку...'),
                      ]),
                    ),
                  ],
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
    if (state.pickupLat != null) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('pickup'),
        point: Point(latitude: state.pickupLat!, longitude: state.pickupLng!),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/icons/pickup.png'),
        )),
      ));
    }
    if (state.destLat != null) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('dest'),
        point: Point(latitude: state.destLat!, longitude: state.destLng!),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/icons/dest.png'),
        )),
      ));
    }
    return objects;
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;

  const _AddressField({
    required this.controller, required this.hint,
    required this.icon, required this.iconColor,
    this.readOnly = false, this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: readOnly,
    onSubmitted: onSubmitted,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: iconColor, size: 18),
    ),
  );
}

class _PriceCard extends StatelessWidget {
  final TripEstimate estimate;
  const _PriceCard({required this.estimate});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(children: [
      const Icon(Icons.route_outlined, color: AppTheme.textSecondary, size: 18),
      const SizedBox(width: 8),
      Text('${estimate.distanceKm.toStringAsFixed(1)} км',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
      const Spacer(),
      Text('${estimate.priceKzt} ₸',
        style: const TextStyle(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _PriceLoading extends StatelessWidget {
  const _PriceLoading();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      SizedBox(width: 16, height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
      SizedBox(width: 8),
      Text('Считаем стоимость...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ],
  );
}
