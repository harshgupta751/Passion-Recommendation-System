import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/closet_provider.dart';
import '../widgets/clothing_card.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/closet_search_bar.dart';
import '../widgets/item_status_sheet.dart';

class ClosetScreen extends ConsumerStatefulWidget {
  const ClosetScreen({super.key});

  @override
  ConsumerState<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends ConsumerState<ClosetScreen> {
  final _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(closetProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final closetState = ref.watch(closetProvider);
    final filter = ref.watch(closetFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: AppColors.backgroundPrimary,
            expandedHeight: 0,
            toolbarHeight: 60,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Digital Closet',
                  style: AppTypography.heading1(color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isGridView = !_isGridView),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.borderDefault, width: 0.5),
                        ),
                        child: Icon(
                          _isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppColors.accentBlue, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: ClosetSearchBar(
                onChanged: (q) {
                  ref.read(closetFilterProvider.notifier).update(
                    (s) => s.copyWith(searchQuery: q),
                  );
                },
              ),
            ),
          ),

          // Category filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: CategoryFilterBar(
                selected: filter.category,
                onSelected: (cat) {
                  ref.read(closetFilterProvider.notifier).update(
                    (s) => s.copyWith(category: cat),
                  );
                },
              ),
            ),
          ),

          // Count + view toggle header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${closetState.totalCount} ITEMS',
                    style: AppTypography.label(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View All',
                      style: AppTypography.body2(color: AppColors.accentBlue),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading state
          if (closetState.isLoading)
            SliverToBoxAdapter(child: _buildShimmerGrid())
          else if (closetState.error != null)
            SliverToBoxAdapter(child: _buildError(closetState.error!))
          else if (closetState.items.isEmpty)
            SliverToBoxAdapter(child: _buildEmpty())
          else
            _isGridView
                ? _buildGrid(closetState)
                : _buildList(closetState),

          // Load more indicator
          if (closetState.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                    ),
                  ),
                ),
              ),
            ),

          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // FAB to add items
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildGrid(ClosetState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final item = state.items[i];
            return ClothingCard(
              item: item,
              onTap: () => context.push('/closet/item/${item.id}'),
              onStatusTap: () => _showStatusSheet(item),
              onAiStylist: () => context.push(
                '/stylist/outfit?itemId=${item.id}',
              ),
            )
                .animate(delay: Duration(milliseconds: (i % 6) * 60))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.08, end: 0);
          },
          childCount: state.items.length,
        ),
      ),
    );
  }

  Widget _buildList(ClosetState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final item = state.items[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClothingCard(
                item: item,
                isListView: true,
                onTap: () => context.push('/closet/item/${item.id}'),
                onStatusTap: () => _showStatusSheet(item),
                onAiStylist: () =>
                    context.push('/stylist/outfit?itemId=${item.id}'),
              ),
            )
                .animate(delay: Duration(milliseconds: i * 40))
                .fadeIn(duration: 250.ms)
                .slideX(begin: 0.04, end: 0);
          },
          childCount: state.items.length,
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 6,
        itemBuilder: (_, i) => _ShimmerCard(tall: i % 3 == 0),
      ),
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.borderDefault, width: 0.5),
              ),
              child: const Icon(Icons.checkroom_outlined, color: AppColors.textTertiary, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Your closet is empty.', style: AppTypography.heading3(color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Add your first item to get started.', style: AppTypography.body2(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load items.', style: AppTypography.body1(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.read(closetProvider.notifier).refresh(),
              child: Text('Retry', style: AppTypography.body2(color: AppColors.accentBlue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.addItem),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.accentBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }

  void _showStatusSheet(item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemStatusSheet(
        item: item,
        onStatusSelected: (status) {
          ref.read(closetProvider.notifier).updateItemStatus(item.id, status);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final bool tall;
  const _ShimmerCard({this.tall = false});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        height: widget.tall ? 260 : 200,
        decoration: BoxDecoration(
          color: Color.lerp(
            AppColors.backgroundCard,
            AppColors.backgroundElevated,
            _animation.value,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderDefault, width: 0.5),
        ),
      ),
    );
  }
}