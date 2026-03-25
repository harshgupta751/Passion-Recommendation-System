import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/dio_client.dart';

// ─── Analytics Model ─────────────────────────────────────────────────────

class WardrobeAnalytics {
  final double wardrobeValue;
  final double costPerWear;
  final int totalItems;
  final int usedItems;
  final double utilizationRate;
  final List<ColorBreakdown> colorPalette;
  final CategoryBreakdown categoryBreakdown;
  final List<InsightCard> insights;

  const WardrobeAnalytics({
    required this.wardrobeValue,
    required this.costPerWear,
    required this.totalItems,
    required this.usedItems,
    required this.utilizationRate,
    required this.colorPalette,
    required this.categoryBreakdown,
    required this.insights,
  });
}

class ColorBreakdown {
  final String name;
  final double percentage;
  final String hex;
  const ColorBreakdown({required this.name, required this.percentage, required this.hex});
}

class CategoryBreakdown {
  final int tops;
  final int bottoms;
  final int shoes;
  final int outerwear;
  final int accessories;
  const CategoryBreakdown({required this.tops, required this.bottoms,
    required this.shoes, required this.outerwear, required this.accessories});
}

class InsightCard {
  final String title;
  final String body;
  final bool isHighlighted;
  const InsightCard({required this.title, required this.body, this.isHighlighted = false});
}

// ─── Provider ─────────────────────────────────────────────────────────────

final analyticsProvider = FutureProvider<WardrobeAnalytics>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/analytics/wardrobe');
  final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  return WardrobeAnalytics(
    wardrobeValue: (data['wardrobe_value'] as num).toDouble(),
    costPerWear: (data['cost_per_wear'] as num).toDouble(),
    totalItems: data['total_items'] as int,
    usedItems: data['used_items'] as int,
    utilizationRate: (data['utilization_rate'] as num).toDouble(),
    colorPalette: (data['color_palette'] as List)
        .map((e) => ColorBreakdown(
              name: e['name'] as String,
              percentage: (e['percentage'] as num).toDouble(),
              hex: e['hex'] as String,
            ))
        .toList(),
    categoryBreakdown: CategoryBreakdown(
      tops: (data['categories']?['tops'] as int?) ?? 0,
      bottoms: (data['categories']?['bottoms'] as int?) ?? 0,
      shoes: (data['categories']?['shoes'] as int?) ?? 0,
      outerwear: (data['categories']?['outerwear'] as int?) ?? 0,
      accessories: (data['categories']?['accessories'] as int?) ?? 0,
    ),
    insights: (data['insights'] as List? ?? [])
        .map((e) => InsightCard(
              title: e['title'] as String,
              body: e['body'] as String,
              isHighlighted: e['highlighted'] as bool? ?? false,
            ))
        .toList(),
  );
});

// ─── Screen ───────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            toolbarHeight: 60,
            title: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: AppColors.accentBlue,
                  margin: const EdgeInsets.only(right: 10),
                ),
                Text('Analytics', style: AppTypography.heading1(color: AppColors.textPrimary)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20),
                onPressed: () {},
              ),
            ],
          ),

          analyticsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(80),
                  child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('Failed to load analytics.', style: AppTypography.body1(color: AppColors.textSecondary)),
                ),
              ),
            ),
            data: (analytics) => _AnalyticsContent(analytics: analytics),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final WardrobeAnalytics analytics;
  const _AnalyticsContent({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Value + CPW cards
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'WARDROBE VALUE',
                      value: '\$${analytics.wardrobeValue.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (m) => '${m[1]},',
                          )}',
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'COST PER WEAR',
                      value: '\$${analytics.costPerWear.toStringAsFixed(2)}',
                    ).animate().fadeIn(duration: 400.ms, delay: 80.ms).slideY(begin: 0.1, end: 0),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Utilization
              _buildUtilizationSection().animate().fadeIn(duration: 400.ms, delay: 160.ms),

              const SizedBox(height: 20),

              // Color palette analysis
              _buildColorSection().animate().fadeIn(duration: 400.ms, delay: 240.ms),

              const SizedBox(height: 20),

              // Insights
              Text('INSIGHTS', style: AppTypography.label(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ...analytics.insights.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _InsightTile(card: e.value)
                          .animate(delay: Duration(milliseconds: 320 + e.key * 80))
                          .fadeIn(duration: 350.ms)
                          .slideX(begin: 0.04, end: 0),
                    ),
                  ),

              const SizedBox(height: 20),

              // Category distribution
              _buildCategorySection().animate().fadeIn(duration: 400.ms, delay: 560.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildUtilizationSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('UTILIZATION', style: AppTypography.label(color: AppColors.textSecondary)),
              Text(
                '${(analytics.utilizationRate * 100).toStringAsFixed(0)}% Active',
                style: AppTypography.body2(color: AppColors.accentBlue)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: CircularPercentIndicator(
              radius: 80,
              lineWidth: 12,
              percent: analytics.utilizationRate,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${analytics.usedItems}',
                    style: AppTypography.heading1(color: AppColors.textPrimary),
                  ),
                  Text('ITEMS USED', style: AppTypography.caption(color: AppColors.textSecondary)),
                ],
              ),
              progressColor: AppColors.accentBlue,
              backgroundColor: AppColors.backgroundTertiary,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1200,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.accentBlue, label: 'Regularly Worn'),
              const SizedBox(width: 20),
              _LegendDot(color: AppColors.textTertiary, label: 'Unworn (30+ Days)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COLOR PALETTE ANALYSIS', style: AppTypography.label(color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          ...analytics.colorPalette.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: Color(int.parse('FF${c.hex.replaceAll('#', '')}', radix: 16)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(c.name.toUpperCase(), style: AppTypography.caption(color: AppColors.textSecondary)),
                        ],
                      ),
                      Text('${c.percentage.toStringAsFixed(0)}%',
                          style: AppTypography.caption(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: c.percentage / 100,
                      minHeight: 4,
                      backgroundColor: AppColors.backgroundTertiary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(int.parse('FF${c.hex.replaceAll('#', '')}', radix: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final cats = [
      ('TOPS', analytics.categoryBreakdown.tops),
      ('BOTTOMS', analytics.categoryBreakdown.bottoms),
      ('SHOES', analytics.categoryBreakdown.shoes),
      ('OUTERWEAR', analytics.categoryBreakdown.outerwear),
      ('ACCESSORIES', analytics.categoryBreakdown.accessories),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATEGORY DISTRIBUTION', style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(
          children: cats.map((c) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderDefault, width: 0.5),
              ),
              child: Column(
                children: [
                  Text('${c.$2}', style: AppTypography.heading2(color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(c.$1, style: AppTypography.caption(color: AppColors.textTertiary)),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption(color: AppColors.textTertiary)),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.heading1(color: AppColors.textPrimary)
              .copyWith(fontSize: 26)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final InsightCard card;
  const _InsightTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: card.isHighlighted ? AppColors.accentBlue : AppColors.borderDefault,
          width: card.isHighlighted ? 1 : 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.isHighlighted)
            Container(
              width: 3,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title.toUpperCase(),
                    style: AppTypography.label(
                      color: card.isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
                    )),
                const SizedBox(height: 6),
                Text(card.body,
                    style: AppTypography.body2(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}