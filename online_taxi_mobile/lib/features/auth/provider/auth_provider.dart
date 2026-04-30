import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

export '../data/auth_repository.dart' show UserRole;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserRole?  role;
  final String?    error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, UserRole? role, String? error}) =>
      AuthState(
        status: status ?? this.status,
        role:   role   ?? this.role,
        error:  error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final role = await _repo.getSavedRole();
    state = role != null
        ? AuthState(status: AuthStatus.authenticated, role: role)
        : const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final role = await _repo.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, role: role);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _msg(e));
    }
  }

  Future<void> register({
    required String phone,
    required String password,
    required String fullName,
    required String email,
    required UserRole role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final r = await _repo.register(
        phone: phone, password: password,
        fullName: fullName, email: email, role: role,
      );
      state = AuthState(status: AuthStatus.authenticated, role: r);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _msg(e));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _msg(Object e) {
    final s = e.toString();
    if (s.contains('UNAUTHENTICATED')) return 'Неверный email или пароль';
    if (s.contains('ALREADY_EXISTS'))  return 'Пользователь уже существует';
    if (s.contains('UNAVAILABLE'))     return 'Сервер недоступен';
    return 'Что-то пошло не так';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);
