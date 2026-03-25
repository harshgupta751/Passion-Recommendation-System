import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Outfit Calendar', style: AppTypography.heading3(color: AppColors.textPrimary)),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: Text('Plan your outfits by date.', style: AppTypography.body1(color: AppColors.textSecondary)),
      ),
    );
  }
}