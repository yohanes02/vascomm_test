import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/placeholder_image.dart';

/// Hero banner at the top of the home screen ("Solusi, Kesehatan Anda").
///
/// Unlike [ServiceFeatureCard] this one is a one-off: it carries a filled
/// CTA button and carousel dots, and its title mixes two weights
/// ([title] regular + [titleEmphasis] bold) the way the design does.
class PromoBannerCard extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;

  /// Regular-weight first half of the headline.
  final String title;

  /// Bold second half of the headline. Omit for a single-weight title.
  final String? titleEmphasis;

  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onCtaPressed;

  /// Carousel indicator: [dotCount] dots with [activeDot] widened.
  /// Pass `dotCount: 0` to hide the indicator entirely — [PromoBannerCarousel]
  /// does that and paints its own [PromoBannerDots] over the card, so the
  /// indicator doesn't slide away with the page.
  final int dotCount;
  final int activeDot;

  /// Keep the bottom padding the indicator needs even when this card isn't
  /// drawing it. Defaults to `dotCount > 0`.
  final bool? reserveDotSpace;

  /// Illustration geometry — same "pops out of the card" treatment as
  /// [ServiceFeatureCard]; the overflow is reserved as top padding.
  final double imageWidth;
  final double imageOverflow;
  final double imageBottomMargin;

  const PromoBannerCard({
    super.key,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.titleEmphasis,
    this.fallbackIcon = Icons.image_outlined,
    this.onCtaPressed,
    this.dotCount = 3,
    this.activeDot = 0,
    this.reserveDotSpace,
    this.imageWidth = 132,
    this.imageOverflow = 16,
    this.imageBottomMargin = 6,
  });

  @override
  Widget build(BuildContext context) {
    final showDots = dotCount > 0;
    final dotSpace = reserveDotSpace ?? showDots;
    return Padding(
      padding: EdgeInsets.only(top: imageOverflow),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              // Soft left-to-right wash: near-white behind the copy, cooling
              // to a pale blue-grey behind the illustration.
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFDFDFF), Color(0xFFE7ECF5)],
              ),
              borderRadius: BorderRadius.circular(20),
              // boxShadow: const [
              //   BoxShadow(
              //     color: Color(0x0F0C2461),
              //     blurRadius: 24,
              //     offset: Offset(0, 10),
              //   ),
              // ],
            ),
            child: Padding(
              // Right padding keeps the copy clear of the illustration
              // column; bottom padding leaves room for the dots.
              // padding: EdgeInsets.fromLTRB(20, 20, imageWidth + 4, dotSpace ? 26 : 20),
              padding: EdgeInsets.fromLTRB(20, 20, imageWidth + 4, dotSpace ? 26 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    // Bounded so a long headline can't overflow the fixed
                    // slide height a carousel gives this card.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                      children: [
                        TextSpan(text: titleEmphasis == null ? title : '$title '),
                        if (titleEmphasis != null)
                          TextSpan(
                            text: titleEmphasis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: onCtaPressed,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(ctaLabel),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -imageOverflow,
            bottom: imageBottomMargin,
            right: 4,
            width: imageWidth,
            child: PlaceholderImage(
              assetPath: assetPath,
              fallbackIcon: fallbackIcon,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              backgroundColor: Colors.transparent,
            ),
          ),
          if (showDots)
            // Painted after the illustration so the dots stay visible where
            // the two overlap, and pinned bottom-right as in the design.
            Positioned(
              right: PromoBannerDots.insetRight,
              bottom: PromoBannerDots.insetBottom,
              child: PromoBannerDots(count: dotCount, activeIndex: activeDot),
            ),
        ],
      ),
    );
  }
}

/// Carousel position indicator drawn in the bottom-right of a
/// [PromoBannerCard]. Shared so [PromoBannerCarousel] can pin one over the
/// paged cards at the same spot.
class PromoBannerDots extends StatelessWidget {
  /// Offsets from the card's bottom-right corner, kept here so the card and
  /// a carousel overlaying it agree on where the dots sit.
  static const insetRight = 20.0;
  static const insetBottom = 14.0;

  final int count;
  final int activeIndex;

  const PromoBannerDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(left: 6),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
