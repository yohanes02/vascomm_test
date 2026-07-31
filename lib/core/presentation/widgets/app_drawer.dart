import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import 'placeholder_image.dart';

/// Shared navigation drawer (profile summary, menu, logout, socials,
/// footer links) used by every authenticated screen.
///
/// The drawer itself spans the full screen width but is transparent: the
/// white panel takes ~84% on the right, and the strip left of it stays
/// see-through so the tinted page shows behind the close button. Tapping
/// that strip dismisses the drawer, same as tapping a normal scrim.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final width = MediaQuery.sizeOf(context).width;
    final stripWidth = (width * 0.16).clamp(56.0, 96.0);

    return Drawer(
      width: width,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: stripWidth,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _CloseButton(onTap: () => Navigator.of(context).pop()),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 76),
                      // The profile summary doubles as a shortcut home.
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          context.goNamed('home');
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            const PlaceholderImage(
                              assetPath: 'assets/images/avatar_placeholder.png',
                              fallbackIcon: Icons.person,
                              width: 48,
                              height: 48,
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      style: const TextStyle(
                                        color: AppColors.navy,
                                        fontSize: 17,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: user?.firstName ?? 'Guest',
                                          style: const TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                        TextSpan(
                                          text: user != null ? ' ${user.lastName}' : '',
                                          style: const TextStyle(fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Membership BBLK',
                                    style: TextStyle(
                                      color: AppColors.slateBlue,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Rows span the panel so the chevrons line up on the
                      // right edge instead of trailing the labels.
                      _DrawerMenuItem(
                        label: 'Profile Saya',
                        onTap: () {
                          Navigator.of(context).pop();
                          context.goNamed('profile');
                        },
                      ),
                      const SizedBox(height: 12),
                      _DrawerMenuItem(
                        label: 'Pengaturan',
                        onTap: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon')),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () async {
                            // Grab the messenger before popping: this
                            // drawer's context is gone by the time logout
                            // finishes.
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.of(context).pop();
                            final failure =
                                await ref.read(authControllerProvider.notifier).logout();
                            if (failure != null) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(failure.message)),
                              );
                            }
                          },
                          child: const Text('Logout'),
                        ),
                      ),
                      const SizedBox(height: 52),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Ikuti kami di',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(width: 14),
                          _SocialIcon(assetName: 'social_facebook', fallbackIcon: Icons.facebook),
                          SizedBox(width: 10),
                          _SocialIcon(assetName: 'social_instagram', fallbackIcon: Icons.camera_alt),
                          SizedBox(width: 10),
                          _SocialIcon(assetName: 'social_twitter', fallbackIcon: Icons.alternate_email),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _FooterLink(label: 'FAQ', onTap: () => _comingSoon(context)),
                          const SizedBox(width: 24),
                          Flexible(
                            child: _FooterLink(
                              label: 'Terms and Conditions',
                              onTap: () => _comingSoon(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: const Icon(Icons.close, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DrawerMenuItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, size: 22, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textFaint,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String assetName;
  final IconData fallbackIcon;

  const _SocialIcon({required this.assetName, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$assetName.png',
      width: 24,
      height: 24,
      // Brand marks aren't in the Material icon set, so until real assets
      // are dropped in these fall back to the closest navy glyph.
      errorBuilder: (context, error, stackTrace) =>
          Icon(fallbackIcon, size: 24, color: AppColors.navy),
    );
  }
}
