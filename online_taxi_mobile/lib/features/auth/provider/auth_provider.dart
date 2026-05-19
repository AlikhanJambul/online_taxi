import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

export '../data/auth_repository.dart' show UserRole, DriverSetupStatus;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus        status;
  final UserRole?         role;
  final DriverSetupStatus driverSetupStatus;
  final String?           error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.driverSetupStatus = DriverSetupStatus.unknown,
    this.error,
  });

  AuthState copyWith({
    AuthStatus?        status,
    UserRole?          role,
    DriverSetupStatus? driverSetupStatus,
    String?            error,
  }) =>
      AuthState(
        status:            status            ?? this.status,
        role:              role              ?? this.role,
        driverSetupStatus: driverSetupStatus ?? this.driverSetupStatus,
        error:             error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final role = await _repo.getSavedRole();
    if (role == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    DriverSetupStatus setupStatus = DriverSetupStatus.unknown;
    if (role == UserRole.driver) {
      setupStatus = await _repo.checkDriverSetupStatus();
    }

    state = AuthState(
      status:            AuthStatus.authenticated,
      role:              role,
      driverSetupStatus: setupStatus,
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final role = await _repo.login(email: email, password: password);

      DriverSetupStatus setupStatus = DriverSetupStatus.unknown;
      if (role == UserRole.driver) {
        setupStatus = await _repo.checkDriverSetupStatus();
      }

      state = AuthState(
        status:            AuthStatus.authenticated,
        role:              role,
        driverSetupStatus: setupStatus,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _msg(e));
    }
  }

  Future<void> register({
    required String   phone,
    required String   password,
    required String   fullName,
    required String   email,
    required UserRole role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final r = await _repo.register(
        phone: phone, password: password,
        fullName: fullName, email: email, role: role,
      );
      state = AuthState(
        status:            AuthStatus.authenticated,
        role:              r,
        driverSetupStatus: r == UserRole.driver
            ? DriverSetupStatus.needsSetup
            : DriverSetupStatus.unknown,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _msg(e));
    }
  }

  void setDriverSetupStatus(DriverSetupStatus status) {
    state = state.copyWith(driverSetupStatus: status);
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
