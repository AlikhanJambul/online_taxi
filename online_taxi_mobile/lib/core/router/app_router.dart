import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/register_screen.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/passenger/ui/map_screen.dart';
import '../../features/passenger/ui/trip_screen.dart';
import '../../features/passenger/ui/passenger_home_screen.dart';
import '../../features/passenger/ui/passenger_profile_screen.dart';
import '../../features/passenger/ui/passenger_shell.dart';
import '../../features/driver/ui/driver_home_screen.dart';
import '../../features/driver/ui/driver_profile_screen.dart';
import '../../features/driver/ui/driver_shell.dart';
import '../../features/driver/ui/driver_map_screen.dart';
import '../../features/driver/ui/active_trip_screen.dart';
import '../../features/driver/ui/driver_setup_screen.dart';
import '../../features/driver/ui/pending_approval_screen.dart';

// GoRouter пересоздаёт весь Navigator при каждой новой инстанции, поэтому
// нельзя пересобирать его на каждое изменение authProvider (ref.watch) —
// это рвёт навигацию (залипающие кнопки, потерянные тапы). Вместо этого
// создаём GoRouter один раз и обновляем redirect через refreshListenable.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: _resolveInitial(ref.read(authProvider)),
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth        = ref.read(authProvider);
      final isAuth      = auth.status == AuthStatus.authenticated;
      final isInitial   = auth.status == AuthStatus.initial;
      final loc         = state.matchedLocation;
      final goingToAuth = loc == '/login' || loc == '/register';

      if (isInitial) return null;
      if (!isAuth && !goingToAuth) return '/login';
      if (isAuth && goingToAuth) return _resolveInitial(auth);

      if (isAuth && auth.role == UserRole.driver) {
        return _driverRedirect(auth.driverSetupStatus, loc);
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      GoRoute(path: '/driver/setup',   builder: (_, __) => const DriverSetupScreen()),
      GoRoute(path: '/driver/pending', builder: (_, __) => const PendingApprovalScreen()),

      // Пассажир: shell с нижней навигацией
      ShellRoute(
        builder: (context, state, child) => PassengerShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(path: '/passenger',         builder: (_, __) => const PassengerHomeScreen()),
          GoRoute(path: '/passenger/profile', builder: (_, __) => const PassengerProfileScreen()),
        ],
      ),
      GoRoute(path: '/passenger/map',  builder: (_, __) => const PassengerMapScreen()),
      GoRoute(path: '/passenger/trip', builder: (_, __) => const PassengerTripScreen()),

      // Водитель: shell с нижней навигацией
      ShellRoute(
        builder: (context, state, child) => DriverShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(path: '/driver',         builder: (_, __) => const DriverHomeScreen()),
          GoRoute(path: '/driver/profile', builder: (_, __) => const DriverProfileScreen()),
        ],
      ),
      GoRoute(path: '/driver/map',  builder: (_, __) => const DriverMapScreen()),
      GoRoute(path: '/driver/trip', builder: (_, __) => const DriverActiveTripScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Страница не найдена: ${state.error}')),
    ),
  );
});

String _resolveInitial(AuthState auth) {
  if (auth.status != AuthStatus.authenticated) return '/login';
  if (auth.role == UserRole.driver) return _driverHome(auth.driverSetupStatus);
  return '/passenger';
}

String _driverHome(DriverSetupStatus setup) {
  switch (setup) {
    case DriverSetupStatus.needsSetup: return '/driver/setup';
    case DriverSetupStatus.pending:
    case DriverSetupStatus.rejected:   return '/driver/pending';
    default:                           return '/driver';
  }
}

String? _driverRedirect(DriverSetupStatus setup, String loc) {
  if (setup == DriverSetupStatus.needsSetup && !loc.startsWith('/driver/setup')) {
    return '/driver/setup';
  }
  // pending — всегда на экран ожидания, даже если только что отправили
  // форму повторной заявки и физически ещё находимся на /driver/setup
  if (setup == DriverSetupStatus.pending && !loc.startsWith('/driver/pending')) {
    return '/driver/pending';
  }
  // rejected — тоже на экран ожидания, но даём остаться на /driver/setup,
  // если пользователь как раз заполняет повторную заявку
  if (setup == DriverSetupStatus.rejected &&
      !loc.startsWith('/driver/pending') && !loc.startsWith('/driver/setup')) {
    return '/driver/pending';
  }
  if (setup == DriverSetupStatus.approved &&
      (loc.startsWith('/driver/setup') || loc.startsWith('/driver/pending'))) {
    return '/driver';
  }
  return null;
}
