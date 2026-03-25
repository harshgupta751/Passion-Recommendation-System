import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/AuthPrimaryButton.dart';

class StyleQuizScreen extends ConsumerStatefulWidget {
  const StyleQuizScreen({super.key});

  @override
  ConsumerState<StyleQuizScreen> createState() => _StyleQuizScreenState();
}

class _StyleQuizScreenState extends ConsumerState<StyleQuizScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final Map<String, String> _answers = {};

  static const _questions = [
    _QuizQuestion(
      id: 'persona',
      prompt: 'How would you describe your style?',
      subtitle: 'Select the one that resonates most.',
      options: [
        _QuizOption('Minimalist', 'Clean lines, neutral palette'),
        _QuizOption('Classic', 'Timeless, refined essentials'),
        _QuizOption('Streetwear', 'Urban, bold, contemporary'),
        _QuizOption('Business', 'Sharp, professional, polished'),
      ],
    ),
    _QuizQuestion(
      id: 'palette',
      prompt: 'What is your dominant color palette?',
      subtitle: 'We use this to refine style suggestions.',
      options: [
        _QuizOption('Monochrome', 'Black, white, grey'),
        _QuizOption('Earth tones', 'Beige, brown, olive'),
        _QuizOption('Bold & vibrant', 'Strong contrast, saturated'),
        _QuizOption('Pastels', 'Soft, muted tones'),
      ],
    ),
    _QuizQuestion(
      id: 'occasion',
      prompt: 'What do you dress for most?',
      subtitle: 'Your primary styling context.',
      options: [
        _QuizOption('Work & Office', 'Professional daily wear'),
        _QuizOption('Social & Events', 'Going out, occasions'),
        _QuizOption('Everyday casual', 'Relaxed, versatile'),
        _QuizOption('All of the above', 'Balanced wardrobe'),
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    // Save style preferences to backend
    context.go(AppRoutes.closet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STYLE PROFILE',
                    style: AppTypography.label(color: AppColors.accentBlue),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.closet),
                    child: Text(
                      'Skip',
                      style: AppTypography.body2(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: AnimatedSmoothIndicator(
                activeIndex: _currentPage,
                count: _questions.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 4,
                  dotWidth: 4,
                  activeDotColor: AppColors.accentBlue,
                  dotColor: AppColors.borderStrong,
                  expansionFactor: 8,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return _QuizPage(
                    question: q,
                    selected: _answers[q.id],
                    onSelect: (value) {
                      setState(() => _answers[q.id] = value);
                    },
                  );
                },
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
              child: AuthPrimaryButton(
                label: _currentPage < _questions.length - 1 ? 'Continue' : 'Start Styling',
                onPressed: _answers.containsKey(_questions[_currentPage].id)
                    ? _nextPage
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizPage extends StatelessWidget {
  final _QuizQuestion question;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _QuizPage({
    required this.question,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.prompt, style: AppTypography.heading1(color: AppColors.textPrimary))
              .animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 6),
          Text(question.subtitle, style: AppTypography.body2(color: AppColors.textSecondary))
              .animate().fadeIn(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final opt = question.options[i];
                final isSelected = selected == opt.label;
                return _OptionTile(
                  option: opt,
                  isSelected: isSelected,
                  index: i,
                  onTap: () => onSelect(opt.label),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final _QuizOption option;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withOpacity(0.12)
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.borderDefault,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label, style: AppTypography.body1(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary).copyWith(fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400)),
                  const SizedBox(height: 2),
                  Text(option.description, style: AppTypography.body2(color: AppColors.textTertiary)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accentBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.accentBlue : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 200 + index * 80))
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.05, end: 0),
    );
  }
}

class _QuizQuestion {
  final String id;
  final String prompt;
  final String subtitle;
  final List<_QuizOption> options;
  const _QuizQuestion({required this.id, required this.prompt, required this.subtitle, required this.options});
}

class _QuizOption {
  final String label;
  final String description;
  const _QuizOption(this.label, this.description);
}