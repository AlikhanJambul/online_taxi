import 'package:flutter/material.dart';
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
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  UserRole _role = UserRole.passenger;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
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

              _field(_nameCtrl,  'Полное имя', Icons.badge_outlined),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Телефон',    Icons.phone_outlined, type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email',       Icons.mail_outline_rounded, type: TextInputType.emailAddress),
              const SizedBox(height: 12),

              TextField(
                controller: _passCtrl,
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
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? type}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
      );
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
