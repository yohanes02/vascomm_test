import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/presentation/widgets/app_input_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    // Surface login failures as a snackbar without rebuilding the whole tree.
    // Success is handled by the router's redirect logic, not here.
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
                      AppInputField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || !value.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 22),
                      AppInputField(
                        label: 'Password',
                        controller: _passwordController,
                        type: AppInputType.password,
                        validator: (value) =>
                            (value == null || value.length < 6) ? 'At least 6 characters' : null,
                        trailingText: 'Lupa Password anda ?',
                        onTrailingTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        ),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: 'Login',
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                        icon: Icons.arrow_forward,
                        iconAtEnd: true,
                      ),
                      const SizedBox(height: 24),
                      AuthFooter(
                        question: 'Belum punya akun ?',
                        actionLabel: 'Daftar sekarang',
                        onAction: () => context.goNamed('register'),
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
