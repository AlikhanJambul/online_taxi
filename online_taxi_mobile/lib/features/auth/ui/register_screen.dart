import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  UserRole _role  = UserRole.passenger;
  bool _obscure   = true;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = '+7';
    _phoneCtrl.addListener(_enforcePhonePrefix);
  }

  void _enforcePhonePrefix() {
    final text = _phoneCtrl.text;
    if (!text.startsWith('+7')) {
      _phoneCtrl.value = _phoneCtrl.value.copyWith(
        text: '+7',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.removeListener(_enforcePhonePrefix);
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Введите полное имя';
    final trimmed = v.trim();
    if (trimmed.length < 3) return 'Минимум 3 символа';
    if (!RegExp(r"^[a-zA-Zа-яА-ЯёЁ\s\-]+$").hasMatch(trimmed)) {
      return 'Только буквы, пробелы и дефис';
    }
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return 'Введите имя и фамилию';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Введите номер телефона';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (!v.startsWith('+7')) return 'Номер должен начинаться с +7';
    if (digits.length != 11) return 'Введите 10 цифр после +7';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Введите email';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Некорректный email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Введите пароль';
    if (v.length < 6) return 'Минимум 6 символов';
    if (!RegExp(r'[a-zA-Z]').hasMatch(v)) return 'Должна быть хотя бы одна буква';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Должна быть хотя бы одна цифра';
    return null;
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).register(
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      role: _role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth    = ref.watch(authProvider);
    final loading = auth.status == AuthStatus.loading;

    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(next.role == UserRole.driver ? '/driver' : '/passenger');
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Создать\nаккаунт',
                  style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary, height: 1.2, letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),

                const Text('Я хочу:',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _RoleCard(
                    icon: Icons.person_outline_rounded,
                    label: 'Пассажир',
                    selected: _role == UserRole.passenger,
                    onTap: () => setState(() => _role = UserRole.passenger),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _RoleCard(
                    icon: Icons.drive_eta_outlined,
                    label: 'Водитель',
                    selected: _role == UserRole.driver,
                    onTap: () => setState(() => _role = UserRole.driver),
                  )),
                ]),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameCtrl,
                  validator: _validateName,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Полное имя',
                    prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.textSecondary, size: 20),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _phoneCtrl,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_PhoneInputFormatter()],
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: '+7 (XXX) XXX-XX-XX',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary, size: 20),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailCtrl,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: AppTheme.textSecondary, size: 20),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _passCtrl,
                  validator: _validatePassword,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary, size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),

                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                    ),
                    child: Text(auth.error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                  ),
                ],

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: loading ? null : _register,
                  child: loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Зарегистрироваться'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Убедимся что начинается с 7
    if (digits.isEmpty) digits = '7';
    if (!digits.startsWith('7')) digits = '7$digits';
    if (digits.length > 11) digits = digits.substring(0, 11);

    final buf = StringBuffer('+7');
    if (digits.length > 1) {
      buf.write(' (');
      buf.write(digits.substring(1, digits.length.clamp(1, 4)));
      if (digits.length > 4) {
        buf.write(') ');
        buf.write(digits.substring(4, digits.length.clamp(4, 7)));
        if (digits.length > 7) {
          buf.write('-');
          buf.write(digits.substring(7, digits.length.clamp(7, 9)));
          if (digits.length > 9) {
            buf.write('-');
            buf.write(digits.substring(9, digits.length.clamp(9, 11)));
          }
        }
      }
    }

    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(children: [
        Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary, size: 28),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.textSecondary,
          fontSize: 13, fontWeight: FontWeight.w500,
        )),
      ]),
    ),
  );
}
