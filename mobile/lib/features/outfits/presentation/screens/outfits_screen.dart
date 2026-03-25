import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../closet/domain/entities/clothing_item.dart';
import '../../../closet/providers/closet_provider.dart';

// ─── Outfit entity ────────────────────────────────────────────────────────

class Outfit {
  final String id;
  final String name;
  final List<String> itemIds;
  final List<ClothingItem>? items;
  final String? occasion;
  final DateTime? lastWornDate;
  final int wearCount;
  final bool isFavorite;
  final DateTime createdAt;

  const Outfit({
    required this.id,
    required this.name,
    required this.itemIds,
    this.items,
    this.occasion,
    this.lastWornDate,
    this.wearCount = 0,
    this.isFavorite = false,
    required this.createdAt,
  });
}

// ─── Outfits screen ───────────────────────────────────────────────────────

class OutfitsScreen extends ConsumerWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            toolbarHeight: 60,
            title: Text('Outfits', style: AppTypography.heading1(color: AppColors.textPrimary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined, color: AppColors.textSecondary, size: 22),
                onPressed: () => context.push(AppRoutes.calendar),
              ),
            ],
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _QuickActionCard(
                    icon: Icons.add_outlined,
                    label: 'Build Outfit',
                    onTap: () => context.push(AppRoutes.outfitBuilder),
                  ),
                  const SizedBox(width: 10),
                  _QuickActionCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Plan Calendar',
                    onTap: () => context.push(AppRoutes.calendar),
                  ),
                  const SizedBox(width: 10),
                  _QuickActionCard(
                    icon: Icons.luggage_outlined,
                    label: 'Pack Trip',
                    onTap: () {},
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text('SAVED OUTFITS', style: AppTypography.label(color: AppColors.textSecondary)),
            ),
          ),

          // Empty state
          SliverToBoxAdapter(
            child: _buildEmptyState(context).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.borderDefault, width: 0.5),
              ),
              child: const Icon(Icons.style_outlined, color: AppColors.textTertiary, size: 30),
            ),
            const SizedBox(height: 16),
            Text('No outfits yet.', style: AppTypography.heading3(color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Build one or let AI suggest a complete look.',
                style: AppTypography.body2(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.aiStylist),
              child: Text('Get AI Suggestions', style: AppTypography.body2(color: AppColors.accentBlue)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderDefault, width: 0.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(height: 6),
              Text(label, style: AppTypography.caption(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}