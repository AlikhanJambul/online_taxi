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

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  String initialLocation = '/login';
  if (auth.status == AuthStatus.authenticated) {
    initialLocation = auth.role == UserRole.driver ? '/driver' : '/passenger';
  }

  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) {
      final isAuth    = auth.status == AuthStatus.authenticated;
      final isInitial = auth.status == AuthStatus.initial;
      final goingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isInitial) return null;
      if (!isAuth && !goingToAuth) return '/login';
      if (isAuth && goingToAuth) {
        return auth.role == UserRole.driver ? '/driver' : '/passenger';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
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
