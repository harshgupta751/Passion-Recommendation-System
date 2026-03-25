import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SocialAuthButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onPressed;
  final Color? accentColor;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onPressed,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.backgroundTertiary,
          side: BorderSide(
            color: accentColor?.withOpacity(0.4) ?? AppColors.borderDefault,
            width: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: accentColor?.withOpacity(0.15) ??
                    AppColors.backgroundElevated,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label.contains('Google') ? 'G' : 'I',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accentColor ?? AppColors.accentBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.button(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}