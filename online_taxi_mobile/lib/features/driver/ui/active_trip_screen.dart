import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../provider/driver_provider.dart';
import '../../../core/theme/app_theme.dart';

class DriverActiveTripScreen extends ConsumerWidget {
  const DriverActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider);
    final trip  = state.incomingTrip;

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (ctrl) => ctrl.moveCamera(
              CameraUpdate.newCameraPosition(const CameraPosition(
                target: Point(latitude: 51.1605, longitude: 71.4704),
                zoom: 14,
              )),
            ),
          ),

          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: _StatusChip()),
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

                  if (trip != null) ...[
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
                      const Text('Оплата', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      Text('${trip.priceKzt} ₸', style: const TextStyle(
                        color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  ElevatedButton(
                    onPressed: () {
                      ref.read(driverProvider.notifier).completeTrip();
                      context.pop();
                    },
                    child: const Text('Завершить поездку'),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.border),
    ),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.directions_car_rounded, color: AppTheme.primary, size: 14),
      SizedBox(width: 8),
      Text('Поездка активна', style: TextStyle(
        color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );
}
