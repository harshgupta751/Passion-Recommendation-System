import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../closet/domain/entities/clothing_item.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class SuggestedItem {
  final String category;
  final String name;
  final String colorDescription;
  final String? imageUrl;
  final String amazonUrl;
  final String flipkartUrl;
  final double matchScore;
  final String reason;

  const SuggestedItem({
    required this.category,
    required this.name,
    required this.colorDescription,
    this.imageUrl,
    required this.amazonUrl,
    required this.flipkartUrl,
    required this.matchScore,
    required this.reason,
  });

  factory SuggestedItem.fromJson(Map<String, dynamic> json) => SuggestedItem(
        category: json['category'] as String,
        name: json['name'] as String,
        colorDescription: json['color_description'] as String,
        imageUrl: json['image_url'] as String?,
        amazonUrl: json['amazon_url'] as String,
        flipkartUrl: json['flipkart_url'] as String,
        matchScore: (json['match_score'] as num).toDouble(),
        reason: json['reason'] as String,
      );
}

class OutfitSuggestionResult {
  final ClothingItem baseItem;
  final List<SuggestedItem> suggestions;
  final String styleNote;

  const OutfitSuggestionResult({
    required this.baseItem,
    required this.suggestions,
    required this.styleNote,
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final outfitSuggestionProvider =
    FutureProvider.family<OutfitSuggestionResult, String>((ref, itemId) async {
  final dio = ref.read(dioProvider);

  final itemRes = await dio.get('/closet/items/$itemId');
  final baseItem = ClothingItem.fromJson(
    (itemRes.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
  );

  final suggestRes = await dio.post('/ai/outfit-suggestions', data: {
    'item_id': itemId,
    'limit': 4,
  });

  final data = suggestRes.data as Map<String, dynamic>;
  final suggestions = (data['data']['suggestions'] as List)
      .map((e) => SuggestedItem.fromJson(e as Map<String, dynamic>))
      .toList();

  return OutfitSuggestionResult(
    baseItem: baseItem,
    suggestions: suggestions,
    styleNote: data['data']['style_note'] as String? ?? '',
  );
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class OutfitSuggestionScreen extends ConsumerWidget {
  final String? baseItemId;
  const OutfitSuggestionScreen({super.key, this.baseItemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (baseItemId == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Text(
            'No item selected.',
            style: AppTypography.body1(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final resultAsync = ref.watch(outfitSuggestionProvider(baseItemId!));

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: resultAsync.when(
        loading: () => _buildLoading(),
        error: (e, _) => _buildError(context),
        data: (result) => _OutfitSuggestionView(result: result),
      ),
    );
  }

  Widget _buildLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.backgroundPrimary,
          leading: const BackButton(),
          title: Text(
            'AI STYLIST',
            style: AppTypography.label(color: AppColors.textPrimary),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                height: 360,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentBlue,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 500.ms)
                      .then()
                      .fadeOut(duration: 500.ms),
                  const SizedBox(width: 12),
                  Text(
                    'Generating your look...',
                    style:
                        AppTypography.body1(color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Analyzing color theory and stylistic trends\nfor the perfect match.',
                style: AppTypography.body2(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to generate suggestions.',
            style: AppTypography.body1(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Go back',
              style: AppTypography.body2(color: AppColors.accentBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutfitSuggestionView extends StatelessWidget {
  final OutfitSuggestionResult result;
  const _OutfitSuggestionView({required this.result});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.backgroundPrimary,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          title: Text(
            'AI STYLIST',
            style: AppTypography.label(color: AppColors.textPrimary),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _BaseItemCard(item: result.baseItem),
          ),
        ),

        if (result.styleNote.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accentBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.styleNote,
                        style: AppTypography.body2(
                            color: AppColors.accentBlue),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ),
          ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COMPLETE THE LOOK',
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                        color: AppColors.borderDefault, width: 0.5),
                  ),
                  child: Text(
                    '${result.suggestions.length} Suggestions',
                    style: AppTypography.caption(
                        color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SuggestionCard(item: result.suggestions[i])
                    .animate(
                        delay: Duration(milliseconds: 400 + i * 120))
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),
              ),
              childCount: result.suggestions.length,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _ActionBar()
                .animate()
                .fadeIn(duration: 400.ms, delay: 800.ms)
                .slideY(begin: 0.1, end: 0),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _BaseItemCard extends StatelessWidget {
  final ClothingItem item;
  const _BaseItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg - 1),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) =>
                  Container(color: AppColors.backgroundTertiary),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.backgroundTertiary,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.textTertiary,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.lg - 1),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BASE LAYER SELECTION',
                    style: AppTypography.label(color: AppColors.accentBlue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: AppTypography.heading2(color: Colors.white),
                  ),
                  Text(
                    [item.color, item.fabric]
                        .where((e) => e != null)
                        .join(' | '),
                    style: AppTypography.body2(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          curve: Curves.easeOutCubic,
        );
  }
}

class _SuggestionCard extends StatelessWidget {
  final SuggestedItem item;
  const _SuggestionCard({required this.item});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md - 1),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.checkroom_outlined,
                    color: AppColors.textTertiary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.toUpperCase(),
                  style: AppTypography.label(color: AppColors.accentBlue)
                      .copyWith(fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  item.name,
                  style: AppTypography.body1(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  item.colorDescription,
                  style:
                      AppTypography.body2(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _BuyButton(
                      label: 'AMAZON',
                      color: AppColors.amazonOrange,
                      onTap: () => _openUrl(item.amazonUrl),
                    ),
                    const SizedBox(width: 8),
                    _BuyButton(
                      label: 'FLIPKART',
                      color: AppColors.flipkartBlue,
                      onTap: () => _openUrl(item.flipkartUrl),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BuyButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: AppTypography.caption(color: Colors.white)
              .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
    );
  }
}

class _ActionBar extends StatefulWidget {
  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar> {
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.view_in_ar_outlined, size: 18),
              label: Text(
                'Try On Virtually',
                style: AppTypography.button(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isFavorited = !_isFavorited);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _isFavorited
                  ? AppColors.error.withOpacity(0.15)
                  : AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _isFavorited
                    ? AppColors.error.withOpacity(0.5)
                    : AppColors.borderDefault,
                width: 0.5,
              ),
            ),
            child: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited
                  ? AppColors.error
                  : AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}