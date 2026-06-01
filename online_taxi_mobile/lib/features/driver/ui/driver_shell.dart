import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class DriverShell extends StatelessWidget {
  final Widget child;
  final String location;

  const DriverShell({super.key, required this.location, required this.child});

  int get _currentIndex => location.startsWith('/driver/profile') ? 1 : 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    body: child,
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => context.go(i == 0 ? '/driver' : '/driver/profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    ),
  );
}
