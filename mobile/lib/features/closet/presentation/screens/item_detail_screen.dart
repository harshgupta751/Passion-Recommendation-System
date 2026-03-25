import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../providers//closet_provider.dart';
import '../../domain/entities/clothing_item.dart';

final _itemDetailProvider =
    FutureProvider.family<ClothingItem, String>((ref, id) async {
  final repo = ref.read(closetRepositoryProvider);
  return repo.getItem(id);
});

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(_itemDetailProvider(itemId));

    return itemAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(child: CircularProgressIndicator(
          color: AppColors.accentBlue, strokeWidth: 2)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text('Failed to load item.',
            style: AppTypography.body1(color: AppColors.textSecondary))),
      ),
      data: (item) => _ItemDetailView(item: item),
    );
  }
}

class _ItemDetailView extends ConsumerStatefulWidget {
  final ClothingItem item;
  const _ItemDetailView({required this.item});

  @override
  ConsumerState<_ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends ConsumerState<_ItemDetailView> {
  late ClothingItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _logWear() async {
    try {
      final repo = ref.read(closetRepositoryProvider);
      final updated = await repo.logWear(_item.id);
      setState(() => _item = updated);
      ref.read(closetProvider.notifier).addItemLocally(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Wear logged.', style: AppTypography.body2(color: AppColors.textPrimary)),
          backgroundColor: AppColors.backgroundElevated,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => context.push('/stylist/outfit?itemId=${_item.id}'),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text('Style', style: AppTypography.caption(color: Colors.white)
                          .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: _item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.backgroundTertiary),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.backgroundTertiary,
                  child: const Icon(Icons.image_outlined, color: AppColors.textTertiary, size: 48),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status row
                  Row(
                    children: [
                      Expanded(
                        child: Text(_item.name,
                            style: AppTypography.heading1(color: AppColors.textPrimary)),
                      ),
                      _StatusPill(status: _item.status),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 4),
                  Text(_item.category, style: AppTypography.body2(color: AppColors.textSecondary))
                      .animate().fadeIn(duration: 400.ms, delay: 80.ms),

                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    children: [
                      _StatCard(label: 'WORN', value: '${_item.wearCount}x'),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'COST / WEAR',
                        value: _item.costPerWear > 0
                            ? '\$${_item.costPerWear.toStringAsFixed(2)}'
                            : '—',
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'LAST WORN',
                        value: _item.lastWornDate != null
                            ? DateFormat('MMM d').format(_item.lastWornDate!)
                            : 'Never',
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 160.ms),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.borderDefault, thickness: 0.5),
                  const SizedBox(height: 24),

                  // Details grid
                  _buildDetailsSection(),

                  const SizedBox(height: 24),

                  // Tags
                  if (_item.tags.isNotEmpty) ...[
                    Text('TAGS', style: AppTypography.label(color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _item.tags.map((tag) => _TagChip(label: tag)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Occasions
                  if (_item.occasions.isNotEmpty) ...[
                    Text('OCCASIONS', style: AppTypography.label(color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _item.occasions.map((o) => _TagChip(label: o)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  _buildActions(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final details = <(String, String?)>[
      ('Brand', _item.brand),
      ('Color', _item.color),
      ('Fabric', _item.fabric),
      ('Season', _item.season),
      ('Purchase price', _item.purchasePrice != null
          ? '\$${_item.purchasePrice!.toStringAsFixed(2)}'
          : null),
    ].where((d) => d.$2 != null).toList();

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DETAILS', style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        ...details.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d.$1, style: AppTypography.body2(color: AppColors.textSecondary)),
                Text(d.$2!, style: AppTypography.body2(color: AppColors.textPrimary)
                    .copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _logWear,
            icon: const Icon(Icons.how_to_reg_outlined, size: 18),
            label: Text('Log Wear Today', style: AppTypography.button(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text('Edit', style: AppTypography.button()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(closetProvider.notifier)
                      .deleteItem(_item.id)
                      .then((_) => context.pop()),
                  icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                  label: Text('Delete', style: AppTypography.button(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withOpacity(0.4), width: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderDefault, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption(color: AppColors.textTertiary)),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.heading3(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'in_use' => ('IN USE', AppColors.accentBlue),
      'in_laundry' => ('IN LAUNDRY', AppColors.textSecondary),
      'stored' => ('STORED', AppColors.textTertiary),
      _ => ('AVAILABLE', AppColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Text(label, style: AppTypography.caption(color: color)
          .copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
    );
  }
}