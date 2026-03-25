import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key});
  @override
  ConsumerState<OutfitBuilderScreen> createState() => _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends ConsumerState<OutfitBuilderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Build Outfit', style: AppTypography.heading3(color: AppColors.textPrimary)),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined, color: AppColors.textTertiary, size: 48),
            const SizedBox(height: 16),
            Text('Outfit Builder', style: AppTypography.heading3(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Drag & drop items to assemble outfits.',
                style: AppTypography.body2(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}