import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_primary_button.dart';
import '../../widgets/auth_secondary_button.dart';
import '../../widgets/auth_divider.dart';
import '../../widgets/social_auth_button.dart';
import '../../widgets/drobe_text_field.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await ref.read(authStateProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    await ref.read(authStateProvider.notifier).signInWithGoogle();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (prev, next) {
      next.whenOrNull(
        error: (e, __) => _showError(e.toString()),
      );
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Back button
                GestureDetector(
                  onTap: () => context.go(AppRoutes.onboarding),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: AppColors.borderDefault,
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Welcome back.',
                  style: AppTypography.display2(color: AppColors.textPrimary),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Sign in to your wardrobe.',
                  style: AppTypography.body1(color: AppColors.textSecondary),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                const SizedBox(height: 36),

                // Social auth
                Column(
                  children: [
                    SocialAuthButton(
                      label: 'Continue with Google',
                      iconPath: 'assets/icons/google.svg',
                      onPressed: _signInWithGoogle,
                    ),
                    const SizedBox(height: 10),
                    SocialAuthButton(
                      label: 'Continue with Instagram',
                      iconPath: 'assets/icons/instagram.svg',
                      onPressed: () {},
                      accentColor: const Color(0xFFE1306C),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0, delay: 200.ms),

                const SizedBox(height: 28),

                const AuthDivider().animate().fadeIn(duration: 400.ms, delay: 350.ms),

                const SizedBox(height: 28),

                // Email field
                DrobeTextField(
                  controller: _emailController,
                  label: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: 14),

                // Password field
                DrobeTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 4),
                    ),
                    child: Text(
                      'Forgot password?',
                      style: AppTypography.body2(color: AppColors.accentBlue),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 550.ms),

                const SizedBox(height: 28),

                AuthPrimaryButton(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _signIn,
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No account? ',
                      style: AppTypography.body2(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.signUp),
                      child: Text(
                        'Create one',
                        style: AppTypography.body2(color: AppColors.accentBlue)
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.backgroundElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}