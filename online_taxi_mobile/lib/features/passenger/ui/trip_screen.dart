import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/trip_provider.dart';
import '../../../core/theme/app_theme.dart';

class PassengerTripScreen extends ConsumerStatefulWidget {
  const PassengerTripScreen({super.key});
  @override
  ConsumerState<PassengerTripScreen> createState() => _PassengerTripScreenState();
}

class _PassengerTripScreenState extends ConsumerState<PassengerTripScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passengerProvider);
    final trip  = state.trip;

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (ctrl) {
              if (trip != null) {
                ctrl.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: Point(latitude: trip.pickupLat, longitude: trip.pickupLng),
                  zoom: 14,
                )));
              }
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _StatusBadge(status: state.status),
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
}

class _StatusBadge extends StatelessWidget {
  final PassengerFlowStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      PassengerFlowStatus.searching => 'Ищем водителя...',
      PassengerFlowStatus.active    => 'Водитель едет',
      _ => '',
    };
    if (label.isEmpty) return const SizedBox.shrink();
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (status == PassengerFlowStatus.searching)
            const SizedBox(width: 12, height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
          if (status == PassengerFlowStatus.active)
            const Icon(Icons.directions_car_rounded, color: AppTheme.primary, size: 14),
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
      const Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Водитель назначен', style: TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          SizedBox(height: 2),
          Text('Toyota Camry • Белый', style: TextStyle(
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
