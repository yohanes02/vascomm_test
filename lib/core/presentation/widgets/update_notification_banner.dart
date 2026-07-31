import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'dot_grid_pattern.dart';

/// "Get notified about updates" CTA banner shown at the bottom of Home
/// and Profile.
class UpdateNotificationBanner extends StatelessWidget {
  /// Pass [BorderRadius.zero] when the banner runs edge-to-edge.
  final BorderRadius borderRadius;

  const UpdateNotificationBanner({
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navy, AppColors.navyDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 96,
              top: 18,
              child: DotGridPattern(color: Colors.white.withValues(alpha: 0.22)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ingin mendapat update dari kami ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Dapatkan notifikasi',
                              maxLines: 2,
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
