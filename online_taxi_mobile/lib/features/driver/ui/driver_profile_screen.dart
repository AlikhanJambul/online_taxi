import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/provider/auth_provider.dart';
import '../data/driver_repository.dart';
import '../provider/driver_provider.dart';

final _tripHistoryProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(driverRepositoryProvider).getTripHistory(),
);

final _statsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(driverRepositoryProvider).getStats(),
);

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth    = ref.watch(authProvider);
    final driver  = ref.watch(driverProvider);
    final stats   = ref.watch(_statsProvider);
    final history = ref.watch(_tripHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            ref.invalidate(_statsProvider);
            ref.invalidate(_tripHistoryProvider);
            await Future.wait([
              ref.read(_statsProvider.future).catchError((_) {}),
              ref.read(_tripHistoryProvider.future).catchError((_) {}),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Профиль', style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),

                  const SizedBox(height: 24),

                  // Аватар + имя
                  Center(child: Column(children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppTheme.card,
                        border: Border.all(color: AppTheme.border, width: 2),
                      ),
                      child: ClipOval(child: auth.avatarUrl.isNotEmpty
                          ? Image.network(auth.avatarUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatar())
                          : _avatar()),
                    ),
                    const SizedBox(height: 12),
                    Text(auth.name.isNotEmpty ? auth.name : 'Водитель',
                        style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                    if (auth.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(auth.phone, style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ])),

                  const SizedBox(height: 24),

                  // Рейтинг + статистика
                  stats.when(
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: AppTheme.primary))),
                    error: (_, __) => const SizedBox(),
                    data: (s) => Row(children: [
                      Expanded(child: _StatTile(
                        icon: Icons.star_rounded, iconColor: const Color(0xFFFFB300),
                        value: s.rating.toStringAsFixed(1), label: 'Рейтинг')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTile(
                        icon: Icons.route_rounded, iconColor: AppTheme.primary,
                        value: '${s.totalTrips}', label: 'Поездок')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTile(
                        icon: Icons.account_balance_wallet_rounded, iconColor: AppTheme.online,
                        value: '${s.totalEarningsKzt.toInt()} ₸', label: 'Заработок')),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // Статус
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.card, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border)),
                    child: Row(children: [
                      Container(width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: driver.status != DriverStatus.offline
                              ? AppTheme.online : AppTheme.textSecondary,
                          shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Text(driver.status != DriverStatus.offline ? 'На линии' : 'Не в сети',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // История поездок
                  const Text('История поездок', style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  history.when(
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppTheme.primary))),
                    error: (_, __) => _emptyHistory('Не удалось загрузить историю'),
                    data: (items) => items.isEmpty
                        ? _emptyHistory('Завершённых поездок пока нет')
                        : Column(
                            children: items.map((item) => _TripHistoryTile(item: item)).toList()),
                  ),

                  const SizedBox(height: 24),

                  // Выход
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Выйти из аккаунта'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: BorderSide(color: AppTheme.error.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ref.read(driverProvider.notifier).goOffline();
                        ref.read(authProvider.notifier).logout();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar() => Container(
    color: AppTheme.primary.withValues(alpha: 0.15),
    child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 44));

  Widget _emptyHistory(String msg) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.card, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border)),
    child: Center(child: Text(msg,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14))));
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   value;
  final String   label;
  const _StatTile({required this.icon, required this.iconColor,
      required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    decoration: BoxDecoration(
      color: AppTheme.card, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border)),
    child: Column(children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(
        color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
    ]));
}

class _TripHistoryTile extends StatelessWidget {
  final TripHistoryItem item;
  const _TripHistoryTile({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.card, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.radio_button_checked, color: AppTheme.success, size: 14),
        const SizedBox(width: 6),
        Expanded(child: Text(item.pickupAddress, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 14),
        const SizedBox(width: 6),
        Expanded(child: Text(item.destAddress, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
      ]),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(item.finishedAt, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 12)),
        Text('${item.priceKzt} ₸', style: const TextStyle(
            color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
    ]));
}
