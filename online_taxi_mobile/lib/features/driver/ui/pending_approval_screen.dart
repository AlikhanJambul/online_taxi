import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../gen/driver.pbenum.dart';
import '../data/driver_repository.dart';
import '../../auth/provider/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    try {
      final profile = await ref.read(driverRepositoryProvider).getProfile();
      if (!mounted) return;

      if (profile.status == DriverStatus.APPROVED) {
        ref.read(authProvider.notifier).setDriverSetupStatus(DriverSetupStatus.approved);
        if (mounted) context.go('/driver');
      } else if (profile.status == DriverStatus.REJECTED) {
        ref.read(authProvider.notifier).setDriverSetupStatus(DriverSetupStatus.rejected);
      }
    } catch (_) {
      // Ignore network errors, keep polling
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth       = ref.watch(authProvider);
    final isRejected = auth.driverSetupStatus == DriverSetupStatus.rejected;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isRejected ? AppTheme.error : AppTheme.primary).withValues(alpha: 0.12),
                ),
                child: Icon(
                  isRejected ? Icons.cancel_outlined : Icons.hourglass_top_rounded,
                  color: isRejected ? AppTheme.error : AppTheme.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                isRejected ? 'Профиль отклонён' : 'Профиль на проверке',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isRejected
                    ? 'К сожалению, ваш профиль был отклонён.\nОбратитесь в службу поддержки.'
                    : 'Ваши данные отправлены на проверку.\nОбычно это занимает до 24 часов.',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isRejected) ...[
                const SizedBox(height: 40),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ожидаем одобрения...',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
              if (isRejected) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).setDriverSetupStatus(DriverSetupStatus.needsSetup);
                      context.go('/driver/setup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Подать заявку повторно',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                child: Text(
                  'Выйти из аккаунта',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
