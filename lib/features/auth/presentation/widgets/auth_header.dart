import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Headline + subtitle + hero illustration shared by Login and Register.
///
/// The illustration deliberately runs past the screen's right edge (it is
/// laid out at its natural width for [illustrationHeight] and clipped), so
/// [horizontalPadding] is applied to the copy only.
class AuthHeader extends StatelessWidget {
  /// Regular-weight first half of the headline, e.g. "Hai,".
  final String title;

  /// Bold second half, e.g. "Selamat Datang".
  final String titleEmphasis;

  final String subtitle;
  final double illustrationHeight;
  final double horizontalPadding;

  const AuthHeader({
    super.key,
    required this.title,
    required this.titleEmphasis,
    required this.subtitle,
    this.illustrationHeight = 220,
    this.horizontalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(text: '$title '),
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
                style: const TextStyle(
                  color: AppColors.slateBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Image.asset(
          'assets/images/auth_illustration.png',
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
