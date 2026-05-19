import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/register_screen.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/passenger/ui/map_screen.dart';
import '../../features/passenger/ui/trip_screen.dart';
import '../../features/driver/ui/driver_home_screen.dart';
import '../../features/driver/ui/active_trip_screen.dart';
import '../../features/driver/ui/driver_setup_screen.dart';
import '../../features/driver/ui/pending_approval_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: _resolveInitial(auth),
    redirect: (context, state) {
      final isAuth    = auth.status == AuthStatus.authenticated;
      final isInitial = auth.status == AuthStatus.initial;
      final loc       = state.matchedLocation;
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
      GoRoute(path: '/login',           builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',        builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/driver/setup',    builder: (_, __) => const DriverSetupScreen()),
      GoRoute(path: '/driver/pending',  builder: (_, __) => const PendingApprovalScreen()),
      GoRoute(
        path: '/passenger',
        builder: (_, __) => const PassengerMapScreen(),
        routes: [
          GoRoute(path: 'trip', builder: (_, __) => const PassengerTripScreen()),
        ],
      ),
      GoRoute(
        path: '/driver',
        builder: (_, __) => const DriverHomeScreen(),
        routes: [
          GoRoute(path: 'trip', builder: (_, __) => const DriverActiveTripScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Страница не найдена: ${state.error}')),
    ),
  );
});

String _resolveInitial(AuthState auth) {
  if (auth.status != AuthStatus.authenticated) return '/login';
  if (auth.role == UserRole.driver) {
    return _driverHome(auth.driverSetupStatus);
  }
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
  if ((setup == DriverSetupStatus.pending || setup == DriverSetupStatus.rejected) &&
      !loc.startsWith('/driver/pending')) {
    return '/driver/pending';
  }
  if (setup == DriverSetupStatus.approved &&
      (loc.startsWith('/driver/setup') || loc.startsWith('/driver/pending'))) {
    return '/driver';
  }
  return null;
}
