import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String   avatarUrl;
  final double   size;
  final IconData icon;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 44,
    this.icon = Icons.person_rounded,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      color: AppTheme.primary.withValues(alpha: 0.15),
      shape: BoxShape.circle,
    ),
    child: ClipOval(
      child: avatarUrl.isNotEmpty
          ? Image.network(
              avatarUrl,
              width: size, height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(icon, color: AppTheme.primary, size: size * 0.5),
            )
          : Icon(icon, color: AppTheme.primary, size: size * 0.5),
    ),
  );
}
