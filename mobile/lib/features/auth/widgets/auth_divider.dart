import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.borderDefault, thickness: 0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTypography.body2(color: AppColors.textTertiary),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.borderDefault, thickness: 0.5),
        ),
      ],
    );
  }
}