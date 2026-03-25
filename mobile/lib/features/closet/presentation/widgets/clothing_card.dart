import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/clothing_item.dart';

class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onTap;
  final VoidCallback onStatusTap;
  final VoidCallback onAiStylist;
  final bool isListView;

  const ClothingCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onStatusTap,
    required this.onAiStylist,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    return isListView ? _buildListCard(context) : _buildGridCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showContextMenu(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderDefault, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg - 1),
                  ),
                  child: AspectRatio(
                    aspectRatio: 0.85,
                    child: CachedNetworkImage(
                      imageUrl: item.thumbnailUrl ?? item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.backgroundTertiary,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.backgroundTertiary,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textTertiary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Status badge
                if (!item.isAvailable)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _StatusBadge(status: item.status),
                  ),

                // AI Stylist shortcut
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onAiStylist();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.body2(color: AppColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category,
                    style: AppTypography.caption(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderDefault, width: 0.5),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppRadius.md - 1),
              ),
              child: SizedBox(
                width: 72,
                height: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: item.thumbnailUrl ?? item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.backgroundTertiary),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.backgroundTertiary,
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.textTertiary, size: 24),
                  ),
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTypography.body1(color: AppColors.textPrimary)
                                .copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!item.isAvailable) _StatusBadge(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.category}${item.brand != null ? ' · ${item.brand}' : ''}',
                      style: AppTypography.caption(color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.color != null) ...[
                          _ColorDot(colorHex: item.colorHex),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          'Worn ${item.wearCount}x',
                          style: AppTypography.caption(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickActionsSheet(
        item: item,
        onStatusTap: onStatusTap,
        onAiStylist: onAiStylist,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'in_use' => ('IN USE', AppColors.inUseTag),
      'in_laundry' => ('IN LAUNDRY', AppColors.inLaundryTag),
      'stored' => ('STORED', AppColors.storedTag),
      _ => ('', Colors.transparent),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.caption(color: Colors.white)
            .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final String? colorHex;
  const _ColorDot({this.colorHex});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.textTertiary;
    if (colorHex != null) {
      try {
        color = Color(int.parse('FF${colorHex!.replaceAll('#', '')}', radix: 16));
      } catch (_) {}
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onStatusTap;
  final VoidCallback onAiStylist;

  const _QuickActionsSheet({
    required this.item,
    required this.onStatusTap,
    required this.onAiStylist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(item.name, style: AppTypography.heading3(color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                _ActionRow(icon: Icons.auto_awesome_outlined, label: 'Get AI outfit suggestions', onTap: () {
                  Navigator.pop(context);
                  onAiStylist();
                }),
                _ActionRow(icon: Icons.swap_horiz_outlined, label: 'Update status', onTap: () {
                  Navigator.pop(context);
                  onStatusTap();
                }),
                _ActionRow(icon: Icons.local_laundry_service_outlined, label: 'Mark as in laundry', onTap: () => Navigator.pop(context)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Text(label, style: AppTypography.body1(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}