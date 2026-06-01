import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/driver_provider.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth   = ref.watch(authProvider);
    final driver = ref.watch(driverProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: const Text('Профиль',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                )),
            ),

            const SizedBox(height: 24),

            // Аватар
            Center(
              child: Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.card,
                  border: Border.all(color: AppTheme.border, width: 2),
                ),
                child: ClipOval(
                  child: auth.avatarUrl.isNotEmpty
                      ? Image.network(auth.avatarUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultAvatar())
                      : _defaultAvatar(),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                auth.name.isNotEmpty ? auth.name : 'Водитель',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (auth.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(auth.phone,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14)),
              ),
            ],

            const SizedBox(height: 24),

            // Статус водителя
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: driver.status != DriverStatus.offline
                          ? AppTheme.online
                          : AppTheme.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    driver.status != DriverStatus.offline
                        ? 'На линии'
                        : 'Не в сети',
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 15),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _MenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Поддержка',
                onTap: () {},
              ),
            ),

            const Spacer(),

            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Выйти из аккаунта'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(
                        color: AppTheme.error.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    ref.read(driverProvider.notifier).goOffline();
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() => Container(
    color: AppTheme.primary.withValues(alpha: 0.15),
    child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 48),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 15)),
        const Spacer(),
        const Icon(Icons.chevron_right_rounded,
            color: AppTheme.textSecondary, size: 20),
      ]),
    ),
  );
}
