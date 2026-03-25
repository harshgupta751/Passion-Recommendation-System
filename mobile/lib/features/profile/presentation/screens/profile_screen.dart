import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider).valueOrNull;
    final user = authState?.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            toolbarHeight: 60,
            title: Text('Profile', style: AppTypography.heading1(color: AppColors.textPrimary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 22),
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar + name
                  _ProfileHeader(user: user)
                      .animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Style persona
                  if (user?.stylePersona != null)
                    _PersonaCard(persona: user!.stylePersona!)
                        .animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 20),

                  // Menu items
                  ..._menuItems(context, ref).asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _MenuRow(item: e.value)
                          .animate(delay: Duration(milliseconds: 200 + e.key * 60))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.04, end: 0),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _signOut(context, ref),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error.withOpacity(0.4), width: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Sign Out',
                          style: AppTypography.button(color: AppColors.error)),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 600.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_MenuItem> _menuItems(BuildContext context, WidgetRef ref) => [
    _MenuItem(icon: Icons.person_outline, label: 'Style Preferences', onTap: () {}),
    _MenuItem(icon: Icons.straighten_outlined, label: 'Body Measurements', onTap: () {}),
    _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
    _MenuItem(icon: Icons.palette_outlined, label: 'Theme', onTap: () {}),
    _MenuItem(icon: Icons.lock_outline, label: 'Privacy & Security', onTap: () {}),
    _MenuItem(icon: Icons.download_outlined, label: 'Export Data', onTap: () {}),
    _MenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
  ];

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).signOut();
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthUser? user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentBlue.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              (user?.displayName?.isNotEmpty == true
                  ? user!.displayName![0]
                  : user?.email[0] ?? 'U')
                  .toUpperCase(),
              style: AppTypography.heading1(color: AppColors.accentBlue),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? 'Your Profile',
                style: AppTypography.heading2(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                user?.email ?? '',
                style: AppTypography.body2(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final String persona;
  const _PersonaCard({required this.persona});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accentBlue, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STYLE PERSONA', style: AppTypography.caption(color: AppColors.accentBlue)),
              const SizedBox(height: 2),
              Text(persona, style: AppTypography.body1(color: AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;
  const _MenuRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderDefault, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label, style: AppTypography.body1(color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}