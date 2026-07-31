import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Paths of the shipped icon artwork, so call sites never hand-write asset
/// strings.
class AppIcons {
  AppIcons._();

  static const bell = 'assets/icons/bell.png';
  static const menu = 'assets/icons/dashicons_menu.png';
  static const eyePassword = 'assets/icons/eye_password.png';
  static const profile = 'assets/icons/profile_icon.png';
  static const cart = 'assets/icons/shopping_cart.png';
}

/// Renders one of the [AppIcons] bitmaps, falling back to a Material glyph
/// if the file is missing so screens never render a broken image box.
class AppIcon extends StatelessWidget {
  final String asset;
  final IconData fallback;
  final double size;

  /// Tints the artwork. Leave null to keep the icon's own colours — needed
  /// for two-tone marks like [AppIcons.profile].
  final Color? color;

  const AppIcon({
    super.key,
    required this.asset,
    required this.fallback,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        fallback,
        size: size,
        color: color ?? AppColors.navy,
      ),
    );
  }
}

/// Drawer toggle for the top bar, using the project's hamburger artwork
/// instead of Material's thinner default.
class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: Scaffold.of(context).openDrawer,
      icon: const AppIcon(asset: AppIcons.menu, fallback: Icons.menu, size: 22),
    );
  }
}
