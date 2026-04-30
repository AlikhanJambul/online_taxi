import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;
    ref.read(authProvider.notifier).login(email: email, password: password);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_taxi_rounded, color: Colors.black, size: 32),
              ),
              const SizedBox(height: 32),
              const Text(
                'Добро\nпожаловать',
                style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary, height: 1.2, letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Войдите в аккаунт',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
              const SizedBox(height: 40),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded, color: AppTheme.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: AppTheme.textPrimary),
                onSubmitted: (_) => _login(),
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
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                    const SizedBox(width: 8),
                    Text(auth.error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                  ]),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: loading ? null : _login,
                child: loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Войти'),
              ),
              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Нет аккаунта? ',
                  style: TextStyle(color: AppTheme.textSecondary)),
                GestureDetector(
                  onTap: () => context.push('/register'),
                  child: const Text('Зарегистрироваться',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Для теста:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('Пассажир: любой email', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text('Водитель: email с "driver"', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
