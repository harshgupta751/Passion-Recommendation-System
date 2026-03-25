import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/clothing_item.dart';

class ItemStatusSheet extends StatelessWidget {
  final ClothingItem item;
  final ValueChanged<String> onStatusSelected;

  const ItemStatusSheet({
    super.key,
    required this.item,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = [
      ('available', 'Available', Icons.check_circle_outline, AppColors.success),
      ('in_use', 'In Use', Icons.person_outline, AppColors.accentBlue),
      ('in_laundry', 'In Laundry', Icons.local_laundry_service_outlined,
          AppColors.textSecondary),
      ('stored', 'Stored', Icons.inventory_2_outlined, AppColors.textTertiary),
    ];

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
          const SizedBox(height: 12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update status',
                  style: AppTypography.heading3(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  style: AppTypography.body2(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ...statuses.map((s) {
                  final isActive = item.status == s.$1;
                  return GestureDetector(
                    onTap: () => onStatusSelected(s.$1),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? s.$4.withOpacity(0.1)
                            : AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isActive ? s.$4 : AppColors.borderDefault,
                          width: isActive ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(s.$3, color: s.$4, size: 20),
                          const SizedBox(width: 14),
                          Text(
                            s.$2,
                            style: AppTypography.body1(
                              color: isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (isActive) Icon(Icons.check, color: s.$4, size: 16),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}