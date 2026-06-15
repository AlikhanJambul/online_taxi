import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

export '../data/auth_repository.dart' show UserRole, DriverSetupStatus;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus        status;
  final UserRole?         role;
  final DriverSetupStatus driverSetupStatus;
  final String?           error;
  final String            name;
  final String            email;
  final String            phone;
  final String            avatarUrl;

  const AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.driverSetupStatus = DriverSetupStatus.unknown,
    this.error,
    this.name      = '',
    this.email     = '',
    this.phone     = '',
    this.avatarUrl = '',
  });

  AuthState copyWith({
    AuthStatus?        status,
    UserRole?          role,
    DriverSetupStatus? driverSetupStatus,
    String?            error,
    String?            name,
    String?            email,
    String?            phone,
    String?            avatarUrl,
  }) =>
      AuthState(
        status:            status            ?? this.status,
        role:              role              ?? this.role,
        driverSetupStatus: driverSetupStatus ?? this.driverSetupStatus,
        error:             error,
        name:              name              ?? this.name,
        email:             email             ?? this.email,
        phone:             phone             ?? this.phone,
        avatarUrl:         avatarUrl         ?? this.avatarUrl,
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

    final name      = await _repo.getSavedName()      ?? '';
    final email     = await _repo.getSavedEmail()     ?? '';
    final phone     = await _repo.getSavedPhone()     ?? '';
    final avatarUrl = await _repo.getSavedAvatarUrl() ?? '';

    state = AuthState(
      status:            AuthStatus.authenticated,
      role:              role,
      driverSetupStatus: setupStatus,
      name:              name,
      email:             email,
      phone:             phone,
      avatarUrl:         avatarUrl,
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

      final name      = await _repo.getSavedName()      ?? '';
      final phone     = await _repo.getSavedPhone()     ?? '';
      final avatarUrl = await _repo.getSavedAvatarUrl() ?? '';

      state = AuthState(
        status:            AuthStatus.authenticated,
        role:              role,
        driverSetupStatus: setupStatus,
        email:             email,
        name:              name,
        phone:             phone,
        avatarUrl:         avatarUrl,
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
        name:  fullName,
        email: email,
        phone: phone,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _msg(e));
    }
  }

  void setAvatarUrl(String url) {
    state = state.copyWith(avatarUrl: url);
    _repo.saveAvatarUrl(url);
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
