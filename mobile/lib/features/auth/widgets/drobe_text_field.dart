import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DrobeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;

  const DrobeTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      maxLines: maxLines,
      style: AppTypography.body1(color: AppColors.textPrimary),
      cursorColor: AppColors.accentBlue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.body1(color: AppColors.textTertiary),
        floatingLabelStyle:
            AppTypography.caption(color: AppColors.accentBlue).copyWith(fontSize: 11),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 4),
                child: suffixIcon,
              )
            : null,
        prefixIcon: prefixIcon,
      ),
    );
  }
}