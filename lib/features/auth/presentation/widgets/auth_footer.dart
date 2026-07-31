import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "Belum punya akun ? Daftar sekarang" style switch link plus the
/// copyright line, shared by Login and Register.
class AuthFooter extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onAction;

  const AuthFooter({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                question,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copyright, size: 17, color: AppColors.textFaint),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'SILK. all right reserved.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
