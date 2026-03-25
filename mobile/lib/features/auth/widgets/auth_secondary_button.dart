import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AuthSecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderStrong, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(label, style: AppTypography.button(color: AppColors.textPrimary)),
      ),
    );
  }
}