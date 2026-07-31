import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_icon.dart';

/// Cart + notification icon pair shown in the top bar of every
/// authenticated screen (Home, Profile, ...).
class AppTopBarActions extends StatelessWidget {
  /// Draws the red dot on the bell. Wire this to real unread state once
  /// notifications land; it's on by default so the badge is visible.
  final bool hasUnreadNotifications;

  const AppTopBarActions({super.key, this.hasUnreadNotifications = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const AppIcon(asset: AppIcons.cart, fallback: Icons.shopping_cart, size: 22),
          onPressed: () => _comingSoon(context),
        ),
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const AppIcon(asset: AppIcons.bell, fallback: Icons.notifications, size: 22),
              if (hasUnreadNotifications)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      // Ring in the bar's own colour so the dot stays
                      // readable where it overlaps the bell.
                      border: Border.all(color: AppColors.background, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _comingSoon(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}
