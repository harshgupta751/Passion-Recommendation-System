import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.heading3(color: AppColors.textPrimary)),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('APPEARANCE'),
          _SettingRow(
            label: 'Dark Mode',
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (v) {
                ref.read(themeModeProvider.notifier).state =
                    v ? ThemeMode.dark : ThemeMode.light;
              },
              activeColor: AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader('NOTIFICATIONS'),
          _SettingRow(label: 'Daily outfit suggestions', trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.accentBlue)),
          _SettingRow(label: 'Laundry reminders', trailing: Switch(value: false, onChanged: (_) {}, activeColor: AppColors.accentBlue)),
          const SizedBox(height: 20),
          _SectionHeader('DATA'),
          _SettingRow(label: 'Auto-backup wardrobe', trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.accentBlue)),
          _SettingRow(label: 'Export all data', trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTypography.label(color: AppColors.textSecondary)),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _SettingRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body1(color: AppColors.textPrimary)),
          trailing,
        ],
      ),
    );
  }
}