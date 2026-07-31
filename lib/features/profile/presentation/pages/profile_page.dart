import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../../../../core/presentation/widgets/app_input_field.dart';
import '../../../../core/presentation/widgets/app_icon.dart';
import '../../../../core/presentation/widgets/app_top_bar_actions.dart';
import '../../../../core/presentation/widgets/dot_grid_pattern.dart';
import '../../../../core/presentation/widgets/placeholder_image.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/segmented_toggle.dart';
import '../../../../core/presentation/widgets/update_notification_banner.dart';

/// "Profile Saya" screen: membership summary + editable "Data Diri" form.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ktpController;
  bool _isSubmitting = false;
  bool _showDataDiri = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).valueOrNull;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _ktpController = TextEditingController(text: user?.ktpNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ktpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await ref.read(authControllerProvider.notifier).updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          ktpNumber: _ktpController.text.trim(),
        );
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessageFor(error))),
        ),
        data: (_) {
          if (previous is AsyncLoading || previous?.hasValue != true) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved')),
          );
        },
      );
    });

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: const AppMenuButton(),
        actions: const [AppTopBarActions()],
      ),
      body: ListView(
        // No horizontal padding here: the banner at the bottom runs
        // edge-to-edge, so each section owns its own inset. The top inset
        // matches the gap below the toggle, so it sits evenly between the
        // app bar and the card.
        padding: const EdgeInsets.symmetric(vertical: 28),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedToggle(
              leftLabel: 'Profile Saya',
              rightLabel: 'Pengaturan',
              leftSelected: true,
              expanded: false,
              // dense: true,
              alignment: Alignment.center,
              onChanged: (left) {
                if (left) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MembershipCard(
                    firstName: user?.firstName ?? 'Guest',
                    lastName: user?.lastName ?? '',
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Pilih data yang ingin ditampilkan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _DataTab(
                              icon: Icons.contact_page,
                              assetIcon: AppIcons.profile,
                              title: 'Data Diri',
                              subtitle: 'Data diri anda sesuai KTP',
                              selected: _showDataDiri,
                              onTap: () => setState(() => _showDataDiri = true),
                            ),
                            const SizedBox(width: 16),
                            _DataTab(
                              icon: Icons.location_on,
                              title: 'Alamat',
                              subtitle: 'Alamat domisili anda',
                              selected: !_showDataDiri,
                              onTap: () => setState(() => _showDataDiri = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        if (_showDataDiri)
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppInputField(
                                  label: 'Nama Depan',
                                  controller: _firstNameController,
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                                ),
                                const SizedBox(height: 20),
                                AppInputField(
                                  label: 'Nama Belakang',
                                  controller: _lastNameController,
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                                ),
                                const SizedBox(height: 20),
                                AppInputField(
                                  label: 'Email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => (value == null || !value.contains('@'))
                                      ? 'Enter a valid email'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                AppInputField(
                                  label: 'No Telpon',
                                  controller: _phoneController,
                                  type: AppInputType.number,
                                  hintText: 'Masukkan no telpon anda',
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                                ),
                                const SizedBox(height: 20),
                                AppInputField(
                                  label: 'No. KTP',
                                  controller: _ktpController,
                                  type: AppInputType.number,
                                  hintText: 'Masukkan no KTP anda',
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                                ),
                                const SizedBox(height: 24),
                                const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info, size: 20, color: AppColors.navy),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Pastikan profile anda terisi dengan benar, data pribadi anda terjamin keamanannya',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                PrimaryButton(
                                  label: 'Simpan Profile',
                                  isLoading: _isSubmitting,
                                  onPressed: _submit,
                                  icon: Icons.save_outlined,
                                  iconAtEnd: true,
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'Coming soon',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const UpdateNotificationBanner(borderRadius: BorderRadius.zero),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final String firstName;
  final String lastName;

  const _MembershipCard({required this.firstName, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
            // Soft disc bleeding off the top-right corner.
            Positioned(
              right: -60,
              top: -80,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              right: 26,
              top: 44,
              child: DotGridPattern(
                rows: 3,
                columns: 6,
                spacing: 9,
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                  child: Row(
                    children: [
                      const PlaceholderImage(
                        assetPath: 'assets/images/avatar_placeholder.png',
                        fallbackIcon: Icons.person,
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.all(Radius.circular(27)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: const TextStyle(color: Colors.white, fontSize: 17),
                                children: [
                                  TextSpan(
                                    text: firstName,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  TextSpan(
                                    text: lastName.isEmpty ? '' : ' $lastName',
                                    style: const TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Membership BBLK',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Lighter strip carrying the "complete your profile" nudge.
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    // Mirror the card's 20px corners on the top edge; the
                    // bottom pair already comes from the parent ClipRRect.
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: const Text(
                    'Lengkapi profile anda untuk memaksimalkan penggunaan aplikasi',
                    style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the two data selectors. The selected one shows its teal tile
/// plus labels; the other collapses to a plain grey circle.
class _DataTab extends StatelessWidget {
  final IconData icon;

  /// Optional shipped artwork for the selected state (see [AppIcons]).
  final String? assetIcon;

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DataTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.assetIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Both states are a circle with the glyph centred inside — the
    // selected one tinted, holding the shipped artwork where there is one
    // for this tab.
    final badge = Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.tealSoft : AppColors.background,
        shape: BoxShape.circle,
      ),
      child: selected && assetIcon != null
          ? AppIcon(asset: assetIcon!, fallback: icon, size: 26)
          : Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
    );

    if (!selected) {
      return GestureDetector(onTap: onTap, child: badge);
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            badge,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
