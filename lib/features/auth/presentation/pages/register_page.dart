import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/presentation/widgets/app_input_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ktpController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ktpController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await ref.read(authControllerProvider.notifier).register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          ktpNumber: _ktpController.text.trim(),
          password: _passwordController.text,
        );
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessageFor(error))),
        ),
      );
    });

    return Scaffold(
      // Same white surface the profile card's form sits on, rather
      // than the app's grey page background.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Horizontal insets live on the sections, not here — the header's
          // illustration runs off the right edge of the screen.
          padding: const EdgeInsets.only(top: 24, bottom: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Hai,',
                  titleEmphasis: 'Selamat Datang',
                  subtitle: 'Silahkan login untuk melanjutkan',
                ),
                // const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppInputField(
                              label: 'Nama Depan',
                              controller: _firstNameController,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: AppInputField(
                              label: 'Nama Belakang',
                              controller: _lastNameController,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      AppInputField(
                        label: 'No. KTP',
                        controller: _ktpController,
                        type: AppInputType.number,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'KTP number is required' : null,
                      ),
                      const SizedBox(height: 22),
                      AppInputField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 22),
                      AppInputField(
                        label: 'No. Telpon',
                        controller: _phoneController,
                        type: AppInputType.number,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Phone number is required' : null,
                      ),
                      const SizedBox(height: 22),
                      AppInputField(
                        label: 'Password',
                        controller: _passwordController,
                        type: AppInputType.password,
                        validator: (value) =>
                            (value == null || value.length < 6) ? 'At least 6 characters' : null,
                      ),
                      const SizedBox(height: 22),
                      AppInputField(
                        label: 'Konfirmasi Password',
                        controller: _confirmPasswordController,
                        type: AppInputType.password,
                        validator: (value) => (value != _passwordController.text)
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: 'Register',
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                        icon: Icons.arrow_forward,
                        iconAtEnd: true,
                      ),
                      const SizedBox(height: 24),
                      AuthFooter(
                        question: 'Sudah punya akun ?',
                        actionLabel: 'Login sekarang',
                        onAction: () => context.goNamed('login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
