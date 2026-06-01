import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/trip_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/map_markers.dart';

enum _MapField { pickup, destination }

class PassengerMapScreen extends ConsumerStatefulWidget {
  const PassengerMapScreen({super.key});
  @override
  ConsumerState<PassengerMapScreen> createState() => _PassengerMapScreenState();
}

class _PassengerMapScreenState extends ConsumerState<PassengerMapScreen> {
  YandexMapController? _mapCtrl;
  final _pickupCtrl = TextEditingController();
  final _destCtrl   = TextEditingController();

  _MapField  _activeField  = _MapField.destination;
  bool       _mapMoving   = false;
  _MapField? _editingField; // пока открыт BottomSheet ввода — не обновляем это поле с карты

  static const _defaultPos = Point(latitude: 51.1605, longitude: 71.4704);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      final address = await _reverseGeocode(pos.latitude, pos.longitude);

      _pickupCtrl.text = address;
      ref.read(passengerProvider.notifier).setPickup(
        address: address, lat: pos.latitude, lng: pos.longitude,
      );

      _mapCtrl?.moveCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: Point(latitude: pos.latitude, longitude: pos.longitude),
          zoom: 15,
        )),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
      );
    } catch (_) {}
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final marks = await placemarkFromCoordinates(lat, lng);
      if (marks.isNotEmpty) {
        final p = marks.first;
        final street = p.street ?? '';
        final number = p.subThoroughfare ?? p.thoroughfare ?? '';
        if (street.isNotEmpty) {
          return number.isNotEmpty ? '$street, $number' : street;
        }
        if ((p.locality ?? '').isNotEmpty) return p.locality!;
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  void _onCameraPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finished,
  ) async {
    setState(() => _mapMoving = !finished);
    if (!finished) return;
    // Не обновляем поле, пока пользователь вводит адрес вручную
    if (_editingField == _activeField) return;

    final lat = position.target.latitude;
    final lng = position.target.longitude;
    final address = await _reverseGeocode(lat, lng);

    if (!mounted) return;
    if (_activeField == _MapField.pickup) {
      _pickupCtrl.text = address;
      ref.read(passengerProvider.notifier).setPickup(address: address, lat: lat, lng: lng);
    } else {
      _destCtrl.text = address;
      ref.read(passengerProvider.notifier).setDest(address: address, lat: lat, lng: lng);
    }
  }

  Future<void> _openAddressInput(_MapField field) async {
    setState(() {
      _activeField  = field;
      _editingField = field;
    });

    final ctrl = field == _MapField.pickup ? _pickupCtrl : _destCtrl;
    final editCtrl = TextEditingController(text: ctrl.text);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddressInputSheet(
        field:   field,
        initial: ctrl.text,
        onConfirm: (address) async {
          if (address.trim().isEmpty) return;
          Navigator.of(ctx).pop();

          double? lat, lng;
          try {
            final locs = await locationFromAddress(address);
            if (locs.isNotEmpty) {
              lat = locs.first.latitude;
              lng = locs.first.longitude;
            }
          } catch (_) {}

          if (!mounted) return;

          final resolvedAddress = address.trim();
          if (lat != null && lng != null) {
            if (field == _MapField.pickup) {
              _pickupCtrl.text = resolvedAddress;
              ref.read(passengerProvider.notifier)
                  .setPickup(address: resolvedAddress, lat: lat, lng: lng);
            } else {
              _destCtrl.text = resolvedAddress;
              ref.read(passengerProvider.notifier)
                  .setDest(address: resolvedAddress, lat: lat, lng: lng);
            }
            _mapCtrl?.moveCamera(
              CameraUpdate.newCameraPosition(
                  CameraPosition(target: Point(latitude: lat, longitude: lng), zoom: 15)),
              animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.8),
            );
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Адрес не найден, попробуйте уточнить'),
                backgroundColor: AppTheme.error,
              ));
            }
          }
        },
      ),
    );

    if (mounted) setState(() => _editingField = null);
    editCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passengerProvider);
    ref.watch(mapMarkersProvider);

    ref.listen(passengerProvider, (prev, next) {
      if (next.status == PassengerFlowStatus.searching ||
          next.status == PassengerFlowStatus.active) {
        context.push('/passenger/trip');
      }
    });

    final pinColor = _activeField == _MapField.pickup
        ? AppTheme.success
        : AppTheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Карта
          YandexMap(
            onMapCreated: (ctrl) {
              _mapCtrl = ctrl;
              ctrl.moveCamera(CameraUpdate.newCameraPosition(
                const CameraPosition(target: _defaultPos, zoom: 13),
              ));
            },
            onCameraPositionChanged: _onCameraPositionChanged,
            mapObjects: _buildMapObjects(state),
          ),

          // Пин в центре карты
          IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: _mapMoving ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: pinColor,
                      size: 44,
                      shadows: const [Shadow(blurRadius: 8, color: Colors.black38)],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: _mapMoving ? 10 : 6,
                    height: _mapMoving ? 3 : 4,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 80), // сдвиг вверх от нижней панели
                ],
              ),
            ),
          ),

          // Шапка
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                // Переключатель A / B
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    _FieldTab(
                      label: 'A  Откуда',
                      color: AppTheme.success,
                      active: _activeField == _MapField.pickup,
                      onTap: () => setState(() => _activeField = _MapField.pickup),
                    ),
                    const SizedBox(width: 4),
                    _FieldTab(
                      label: 'B  Куда',
                      color: AppTheme.primary,
                      active: _activeField == _MapField.destination,
                      onTap: () => setState(() => _activeField = _MapField.destination),
                    ),
                  ]),
                ),
                const SizedBox(width: 8),
                // Кнопка GPS — вернуться к текущей локации
                GestureDetector(
                  onTap: _initLocation,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Icon(Icons.my_location_rounded,
                      color: AppTheme.textSecondary, size: 20),
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
                  20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
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
                  const SizedBox(height: 14),

                  // Адрес A
                  _AddressRow(
                    label: 'A',
                    labelColor: AppTheme.success,
                    controller: _pickupCtrl,
                    hint: 'Откуда',
                    active: _activeField == _MapField.pickup,
                    loading: _mapMoving && _activeField == _MapField.pickup &&
                        _editingField != _MapField.pickup,
                    onTap: () {
                      setState(() => _activeField = _MapField.pickup);
                      final s = ref.read(passengerProvider);
                      if (s.pickupLat != null) {
                        _mapCtrl?.moveCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                            target: Point(latitude: s.pickupLat!, longitude: s.pickupLng!),
                            zoom: 15,
                          )),
                          animation: const MapAnimation(
                              type: MapAnimationType.smooth, duration: 0.5),
                        );
                      }
                    },
                    onEditTap: () => _openAddressInput(_MapField.pickup),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(children: [
                      Container(width: 2, height: 16, color: AppTheme.border),
                    ]),
                  ),

                  // Адрес B
                  _AddressRow(
                    label: 'B',
                    labelColor: AppTheme.primary,
                    controller: _destCtrl,
                    hint: 'Куда',
                    active: _activeField == _MapField.destination,
                    loading: _mapMoving && _activeField == _MapField.destination &&
                        _editingField != _MapField.destination,
                    onTap: () {
                      setState(() => _activeField = _MapField.destination);
                      final s = ref.read(passengerProvider);
                      if (s.destLat != null) {
                        _mapCtrl?.moveCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                            target: Point(latitude: s.destLat!, longitude: s.destLng!),
                            zoom: 15,
                          )),
                          animation: const MapAnimation(
                              type: MapAnimationType.smooth, duration: 0.5),
                        );
                      }
                    },
                    onEditTap: () => _openAddressInput(_MapField.destination),
                  ),

                  if (state.status == PassengerFlowStatus.estimating) ...[
                    const SizedBox(height: 16),
                    const Center(child: _PriceLoading()),
                  ],
                  if (state.estimate != null &&
                      state.status == PassengerFlowStatus.estimated) ...[
                    const SizedBox(height: 14),
                    _PriceCard(estimate: state.estimate!),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(passengerProvider.notifier).createTrip(),
                      child: const Text('Заказать'),
                    ),
                  ],
                  if (state.status == PassengerFlowStatus.creating) ...[
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          ),
                          SizedBox(width: 10),
                          Text('Создаём поездку...'),
                        ],
                      ),
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
    final m       = ref.read(mapMarkersProvider).valueOrNull;
    if (m == null) return objects;

    if (state.pickupLat != null) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('pickup'),
        point: Point(latitude: state.pickupLat!, longitude: state.pickupLng!),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(m.pickup),
        )),
      ));
    }
    if (state.destLat != null) {
      objects.add(PlacemarkMapObject(
        mapId: const MapObjectId('dest'),
        point: Point(latitude: state.destLat!, longitude: state.destLng!),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(m.destination),
        )),
      ));
    }
    return objects;
  }
}

// ── Виджеты ──────────────────────────────────────────────────────────────────

class _FieldTab extends StatelessWidget {
  final String      label;
  final Color       color;
  final bool        active;
  final VoidCallback onTap;

  const _FieldTab({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: active ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? color : AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    ),
  );
}

class _AddressRow extends StatelessWidget {
  final String                label;
  final Color                 labelColor;
  final TextEditingController controller;
  final String                hint;
  final bool                  active;
  final bool                  loading;
  final VoidCallback          onTap;
  final VoidCallback          onEditTap;

  const _AddressRow({
    required this.label,
    required this.labelColor,
    required this.controller,
    required this.hint,
    required this.active,
    required this.loading,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? labelColor.withValues(alpha: 0.07) : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? labelColor : AppTheme.border,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: labelColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: loading
              ? const Row(children: [
                  SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: AppTheme.textSecondary),
                  ),
                  SizedBox(width: 8),
                  Text('Определяем адрес...',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ])
              : Text(
                  controller.text.isNotEmpty ? controller.text : hint,
                  style: TextStyle(
                    color: controller.text.isNotEmpty
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        // Кнопка редактирования (ввод вручную)
        GestureDetector(
          onTap: onEditTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              Icons.edit_rounded,
              color: active ? labelColor : AppTheme.textSecondary,
              size: 16,
            ),
          ),
        ),
      ]),
    ),
  );
}

// ── Bottom sheet ввода адреса вручную ─────────────────────────────────────────

class _AddressInputSheet extends StatefulWidget {
  final _MapField           field;
  final String              initial;
  final void Function(String) onConfirm;

  const _AddressInputSheet({
    required this.field,
    required this.initial,
    required this.onConfirm,
  });

  @override
  State<_AddressInputSheet> createState() => _AddressInputSheetState();
}

class _AddressInputSheetState extends State<_AddressInputSheet> {
  late final TextEditingController _ctrl;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
    _ctrl.selection = TextSelection(
      baseOffset: 0, extentOffset: _ctrl.text.length,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _searching = true);
    widget.onConfirm(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.field == _MapField.pickup
        ? AppTheme.success
        : AppTheme.primary;
    final label = widget.field == _MapField.pickup ? 'Откуда' : 'Куда';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 16),
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.field == _MapField.pickup ? 'A' : 'B',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Введите адрес — $label',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _confirm(),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Например: ул. Пушкина, 10',
                prefixIcon: Icon(Icons.search_rounded, color: color, size: 20),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                          color: AppTheme.textSecondary, size: 18),
                        onPressed: () => setState(() => _ctrl.clear()),
                      )
                    : null,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: color, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _searching ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
              ),
              child: _searching
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Найти на карте'),
            ),
          ],
        ),
      ),
    );
  }
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
        style: const TextStyle(
          color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _PriceLoading extends StatelessWidget {
  const _PriceLoading();
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(width: 16, height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
      SizedBox(width: 8),
      Text('Считаем стоимость...',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ],
  );
}
