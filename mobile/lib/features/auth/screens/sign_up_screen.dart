import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/AuthPrimaryButton.dart';
import '../widgets/auth_divider.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/drobe_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await ref.read(authStateProvider.notifier).signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to style quiz after registration
      final authState = ref.read(authStateProvider).valueOrNull;
      if (authState?.isAuthenticated == true &&
          authState?.user?.hasCompletedQuiz == false) {
        context.go(AppRoutes.styleQuiz);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onTap: () => context.go(AppRoutes.onboarding),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.borderDefault, width: 0.5),
                    ),
                    child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                  ),
                ),
                const SizedBox(height: 40),

                Text('Create account.', style: AppTypography.display2(color: AppColors.textPrimary))
                    .animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),
                Text('Your intelligent wardrobe awaits.', style: AppTypography.body1(color: AppColors.textSecondary))
                    .animate().fadeIn(duration: 500.ms, delay: 100.ms),

                const SizedBox(height: 36),

                Column(children: [
                  SocialAuthButton(label: 'Continue with Google', iconPath: 'assets/icons/google.svg', onPressed: () {}),
                  const SizedBox(height: 10),
                  SocialAuthButton(label: 'Continue with Instagram', iconPath: 'assets/icons/instagram.svg', onPressed: () {}, accentColor: const Color(0xFFE1306C)),
                ]).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                const SizedBox(height: 28),
                const AuthDivider().animate().fadeIn(duration: 400.ms, delay: 350.ms),
                const SizedBox(height: 28),

                DrobeTextField(
                  controller: _nameController,
                  label: 'Full name',
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: 14),

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
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                const SizedBox(height: 14),

                DrobeTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signUp(),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary, size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                const SizedBox(height: 8),
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy.',
                  style: AppTypography.caption(color: AppColors.textTertiary),
                ).animate().fadeIn(duration: 400.ms, delay: 650.ms),

                const SizedBox(height: 28),

                AuthPrimaryButton(label: 'Create Account', isLoading: _isLoading, onPressed: _signUp)
                    .animate().fadeIn(duration: 400.ms, delay: 700.ms),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppTypography.body2(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.signIn),
                      child: Text('Sign in', style: AppTypography.body2(color: AppColors.accentBlue).copyWith(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}