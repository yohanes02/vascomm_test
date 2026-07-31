import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/placeholder_image.dart';

/// Which edge of the card the illustration sits on.
enum ServiceImageSide { left, right }

/// Reusable "service shortcut" card: title, subtitle and a text CTA on one
/// side, an illustration on the other.
///
/// The illustration deliberately overflows the card's top edge by
/// [imageOverflow] and keeps [imageBottomMargin] of clearance above the
/// bottom edge, so it reads as popping out of the card. The widget reserves
/// that overflow as its own top padding, so callers can lay it out like any
/// ordinary box.
class ServiceFeatureCard extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onTap;

  final ServiceImageSide imageSide;
  final Color backgroundColor;

  /// Horizontal space the illustration occupies inside the card.
  final double imageWidth;

  /// How far the illustration rises above the card's top edge.
  final double imageOverflow;

  /// Gap kept between the illustration and the card's bottom edge.
  final double imageBottomMargin;

  const ServiceFeatureCard({
    super.key,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.fallbackIcon = Icons.image_outlined,
    this.onTap,
    this.imageSide = ServiceImageSide.right,
    this.backgroundColor = Colors.white,
    this.imageWidth = 140,
    this.imageOverflow = 16,
    this.imageBottomMargin = 20,
  });

  @override
  Widget build(BuildContext context) {
    final imageOnLeft = imageSide == ServiceImageSide.left;
    // Text keeps clear of the illustration's column, whichever side it's on.
    final textPadding = EdgeInsets.fromLTRB(
      imageOnLeft ? imageWidth + 24 : 22,
      24,
      imageOnLeft ? 22 : imageWidth + 24,
      24,
    );

    return Padding(
      // Reserve the overflow so the popped-out illustration doesn't collide
      // with whatever sits above this card.
      padding: EdgeInsets.only(top: imageOverflow),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                // colors: [Color(0xFFFDFDFF), Color(0xFFE7ECF5)],
                colors: [Color(0xFFFDFDFF), Color(0xFFE7ECF5)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0C2461),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: textPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      fontSize: 19,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            ctaLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward, size: 18, color: AppColors.navy),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -imageOverflow,
            bottom: imageBottomMargin,
            left: imageOnLeft ? 10 : null,
            right: imageOnLeft ? null : 10,
            width: imageWidth,
            child: Container(
              margin: EdgeInsets.only(left: imageOnLeft ? 10 : 0, right: imageOnLeft ? 0 : 10),
              child: PlaceholderImage(
                assetPath: assetPath,
                fallbackIcon: fallbackIcon,
                // `contain` keeps the illustration whole while it spills past
                // the card edge — `cover` would crop it. Anchoring to the top
                // is what makes the overflow visible: centred, the artwork
                // would just float in the middle of its column.
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                // Transparent so the part sticking out of the card doesn't
                // paint a visible block behind itself.
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
