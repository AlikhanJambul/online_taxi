import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/driver_provider.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth        = ref.watch(authProvider);
    final driver      = ref.watch(driverProvider);
    final firstName   = auth.name.isNotEmpty
        ? auth.name.split(' ').first
        : 'Водитель';
    final isOnline    = driver.status != DriverStatus.offline;
    final isInTrip    = driver.status == DriverStatus.enRoute ||
                        driver.status == DriverStatus.arrived  ||
                        driver.status == DriverStatus.inTrip;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Приветствие
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.drive_eta_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Добро пожаловать',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    Text(firstName,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const Spacer(),
                // Статус-бейдж
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? AppTheme.online.withValues(alpha: 0.15)
                        : AppTheme.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOnline
                          ? AppTheme.online.withValues(alpha: 0.4)
                          : AppTheme.border,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: isOnline ? AppTheme.online : AppTheme.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'На линии' : 'Не в сети',
                      style: TextStyle(
                        color: isOnline
                            ? AppTheme.online
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
              ]),

              const SizedBox(height: 32),

              // Основная карточка-кнопка
              GestureDetector(
                onTap: () => context.push('/driver/map'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isOnline ? AppTheme.online : AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInTrip
                                ? 'Вы в поездке'
                                : isOnline
                                    ? 'Вы на линии'
                                    : 'Принимать заказы',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isInTrip
                                ? 'Нажмите чтобы открыть карту'
                                : isOnline
                                    ? 'Ожидаем входящие заказы...'
                                    : 'Нажмите чтобы начать работу',
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isInTrip
                            ? Icons.directions_car_rounded
                            : isOnline
                                ? Icons.wifi_rounded
                                : Icons.power_settings_new_rounded,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 32),

              const Text('Статистика',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.route_rounded,
                    label: 'Поездок',
                    value: '—',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star_rounded,
                    label: 'Рейтинг',
                    value: '—',
                    iconColor: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Заработок',
                    value: '—',
                    iconColor: AppTheme.online,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = AppTheme.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(children: [
      Icon(icon, color: iconColor, size: 22),
      const SizedBox(height: 8),
      Text(value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          )),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 11)),
    ]),
  );
}
