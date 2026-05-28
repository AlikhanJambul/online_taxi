import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/data/auth_repository.dart';
import '../provider/trip_provider.dart';

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

      // 1. Получаем presigned URL — сервер сам сохраняет file_url в профиль
      final uploadUrl = await repo.getAvatarUploadUrl();
      final fileUrl   = await repo.getAvatarFileUrl();

      // 2. Загружаем файл напрямую в MinIO
      final bytes    = await File(file.path).readAsBytes();
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: bytes,
      );
      if (response.statusCode != 200) throw Exception('upload failed');

      // 3. Обновляем state локально (сервер уже сохранил при шаге 1)
      ref.read(authProvider.notifier).setAvatarUrl(fileUrl);
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
    final auth = ref.watch(authProvider);

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
                icon: Icons.history_rounded,
                label: 'История поездок',
                onTap: () {},
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Поддержка',
                onTap: () {},
              ),
            ),

            const Spacer(),

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
    );
  }
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
