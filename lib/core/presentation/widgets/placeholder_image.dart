import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Renders [assetPath] once a real file exists at that path under
/// `assets/images/`; until then (or if loading fails) falls back to an
/// icon on a tinted background, so screens stay usable while real
/// illustration/photo assets are being added.
class PlaceholderImage extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Where the scaled image sits inside its box — matters when [fit] leaves
  /// slack (e.g. `contain` in a box taller than the artwork).
  final Alignment alignment;

  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;

  const PlaceholderImage({
    super.key,
    required this.assetPath,
    this.fallbackIcon = Icons.image_outlined,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius = BorderRadius.zero,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: backgroundColor ?? AppColors.tealLight,
          alignment: Alignment.center,
          child: Icon(
            fallbackIcon,
            color: iconColor ?? AppColors.navy.withValues(alpha: 0.4),
            size: (width != null && width! < 56) ? width! * 0.5 : 32,
          ),
        ),
      ),
    );
  }
}
