import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/driver_setup_provider.dart';
import '../../../core/theme/app_theme.dart';

class DriverSetupScreen extends ConsumerStatefulWidget {
  const DriverSetupScreen({super.key});

  @override
  ConsumerState<DriverSetupScreen> createState() => _DriverSetupScreenState();
}

class _DriverSetupScreenState extends ConsumerState<DriverSetupScreen> {
  final _carMakeCtrl      = TextEditingController();
  final _carModelCtrl     = TextEditingController();
  final _carColorCtrl     = TextEditingController();
  final _licensePlateCtrl = TextEditingController();
  final _picker           = ImagePicker();

  File? _avatarFile;
  File? _carFile;

  @override
  void initState() {
    super.initState();
    // Сбрасываем стейт предыдущей попытки (например, после отклонения),
    // иначе stage "done" навсегда блокирует кнопку отправки.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverSetupProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _carMakeCtrl.dispose();
    _carModelCtrl.dispose();
    _carColorCtrl.dispose();
    _licensePlateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isAvatar) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      if (isAvatar) {
        _avatarFile = File(picked.path);
      } else {
        _carFile = File(picked.path);
      }
    });
  }

  Future<void> _submit() async {
    if (_avatarFile == null || _carFile == null) {
      _showSnack('Загрузите оба фото');
      return;
    }
    final make  = _carMakeCtrl.text.trim();
    final model = _carModelCtrl.text.trim();
    final color = _carColorCtrl.text.trim();
    final plate = _licensePlateCtrl.text.trim();
    if (make.isEmpty || model.isEmpty || color.isEmpty || plate.isEmpty) {
      _showSnack('Заполните все поля');
      return;
    }

    await ref.read(driverSetupProvider.notifier).submitProfile(
      avatarFile:   _avatarFile!,
      carFile:      _carFile!,
      carMake:      make,
      carModel:     model,
      carColor:     color,
      licensePlate: plate,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final setup     = ref.watch(driverSetupProvider);
    final isLoading = setup.stage != SetupStage.idle && setup.stage != SetupStage.error;

    // Не полагаемся только на реактивный redirect роутера — переходим явно,
    // как только профиль успешно создан/пересоздан.
    ref.listen(driverSetupProvider, (prev, next) {
      if (prev?.stage != SetupStage.done && next.stage == SetupStage.done) {
        context.go('/driver/pending');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Создать профиль',
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Ваше фото'),
            const SizedBox(height: 8),
            _PhotoPicker(
              file:  _avatarFile,
              hint:  'Выбрать фото',
              onTap: () => _pickImage(true),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Фото машины'),
            const SizedBox(height: 8),
            _PhotoPicker(
              file:  _carFile,
              hint:  'Выбрать фото машины',
              onTap: () => _pickImage(false),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Данные автомобиля'),
            const SizedBox(height: 8),
            _Field(controller: _carMakeCtrl,      hint: 'Марка  (Toyota, BMW...)'),
            const SizedBox(height: 12),
            _Field(controller: _carModelCtrl,     hint: 'Модель (Camry, X5...)'),
            const SizedBox(height: 12),
            _Field(controller: _carColorCtrl,     hint: 'Цвет'),
            const SizedBox(height: 12),
            _Field(controller: _licensePlateCtrl, hint: 'Гос. номер', caps: true),
            const SizedBox(height: 16),
            if (setup.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(setup.error!, style: const TextStyle(color: AppTheme.error)),
              ),
              const SizedBox(height: 12),
            ],
            if (isLoading) ...[
              Text(
                _stageLabel(setup.stage),
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  minHeight: 4,
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.border,
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: AppTheme.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Отправить на проверку',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
  );

  String _stageLabel(SetupStage stage) {
    switch (stage) {
      case SetupStage.uploadingAvatar:  return 'Загружаем ваше фото...';
      case SetupStage.uploadingCar:     return 'Загружаем фото машины...';
      case SetupStage.creatingProfile:  return 'Создаём профиль...';
      default: return '';
    }
  }
}

class _PhotoPicker extends StatelessWidget {
  final File?        file;
  final String       hint;
  final VoidCallback onTap;

  const _PhotoPicker({required this.file, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.file(file!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primary, size: 36),
                  const SizedBox(height: 8),
                  Text(hint, style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool   caps;

  const _Field({required this.controller, required this.hint, this.caps = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.words,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }
}
