import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/data/auth_repository.dart';
import '../data/trip_repository.dart';
import '../provider/trip_provider.dart';

final _tripHistoryProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(tripRepositoryProvider).getTripHistory(),
);

class PassengerProfileScreen extends ConsumerStatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  ConsumerState<PassengerProfileScreen> createState() =>
      _PassengerProfileScreenState();
}

class _PassengerProfileScreenState
    extends ConsumerState<PassengerProfileScreen> {
  bool _uploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
    if (file == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final repo = ref.read(authRepositoryProvider);

      // 1. Получаем presigned upload URL и постоянный file URL одним вызовом
      final info = await repo.getAvatarUploadUrl();

      // 2. Загружаем файл напрямую в MinIO
      final bytes    = await File(file.path).readAsBytes();
      final response = await http.put(
        Uri.parse(info.uploadUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: bytes,
      );
      if (response.statusCode != 200) throw Exception('upload failed');

      // 3. Обновляем state локально
      ref.read(authProvider.notifier).setAvatarUrl(info.fileUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth    = ref.watch(authProvider);
    final history = ref.watch(_tripHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            ref.invalidate(_tripHistoryProvider);
            try {
              await ref.read(_tripHistoryProvider.future);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              child: Stack(
                children: [
                  _Avatar(
                    avatarUrl:  auth.avatarUrl,
                    uploading:  _uploadingPhoto,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.bg, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.black, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Имя под аватаром
            Center(
              child: Text(
                auth.name.isNotEmpty ? auth.name : 'Пассажир',
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

            if (auth.email.isNotEmpty) ...[
              const SizedBox(height: 2),
              Center(
                child: Text(auth.email,
                  style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
              ),
            ],

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Поддержка',
                onTap: () {},
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text('История поездок', style: TextStyle(
                color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: history.when(
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppTheme.primary))),
                error: (_, __) => _emptyHistory('Не удалось загрузить историю'),
                data: (items) => items.isEmpty
                    ? _emptyHistory('Завершённых поездок пока нет')
                    : Column(
                        children: items.map((item) => _TripHistoryTile(item: item)).toList()),
              ),
            ),

            const SizedBox(height: 24),

            // Кнопка выхода
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
              child: SizedBox(
                width: double.infinity, height: 50,
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
                    ref.read(passengerProvider.notifier).reset();
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _emptyHistory(String msg) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.card, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border)),
    child: Center(child: Text(msg,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14))));
}

class _Avatar extends StatelessWidget {
  final String avatarUrl;
  final bool   uploading;
  const _Avatar({required this.avatarUrl, required this.uploading});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = avatarUrl.isNotEmpty;

    return Container(
      width: 96, height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.card,
        border: Border.all(color: AppTheme.border, width: 2),
      ),
      child: ClipOval(
        child: uploading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.primary))
            : hasPhoto
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _DefaultAvatar(),
                  )
                : _DefaultAvatar(),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.primary.withValues(alpha: 0.15),
    child: const Icon(Icons.person_rounded,
      color: AppTheme.primary, size: 48),
  );
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon, required this.label, required this.onTap});

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
        Text(label, style: const TextStyle(
          color: AppTheme.textPrimary, fontSize: 15)),
        const Spacer(),
        const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textSecondary, size: 20),
      ]),
    ),
  );
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
      if (item.driverName.isNotEmpty) ...[
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.person_rounded, color: AppTheme.textSecondary, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text('Водитель: ${item.driverName}', overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
        ]),
      ],
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(item.finishedAt, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 12)),
        Text('${item.priceKzt} ₸', style: const TextStyle(
            color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
    ]));
}
