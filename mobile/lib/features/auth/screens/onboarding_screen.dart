import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../widgets//AuthPrimaryButton.dart';
import '../widgets//AuthSecondaryButton.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.backgroundPrimary,
                      Color.lerp(
                        AppColors.backgroundPrimary,
                        AppColors.accentBlueDim.withOpacity(0.4),
                        _bgController.value,
                      )!,
                      AppColors.backgroundPrimary,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // Noise texture overlay (subtle)
          Opacity(
            opacity: 0.03,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/noise.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          // Grid lines
          CustomPaint(
            size: size,
            painter: _GridPainter(),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // Label
                  Text(
                    'INTELLIGENT WARDROBE',
                    style: AppTypography.label(
                      color: AppColors.accentBlue,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms)
                      .slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 12),

                  // Line accent
                  Container(
                    width: 32,
                    height: 1.5,
                    color: AppColors.accentBlue,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 500.ms)
                      .scaleX(begin: 0, end: 1, alignment: Alignment.centerLeft),

                  const SizedBox(height: 20),

                  // Headline
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Redefining\n',
                          style: AppTypography.display1(
                            color: AppColors.textPrimary.withOpacity(0.7),
                          ),
                        ),
                        TextSpan(
                          text: 'Personal Style\n',
                          style: AppTypography.display1(
                            color: AppColors.textPrimary,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 40,
                          ),
                        ),
                        TextSpan(
                          text: 'through Intelligence.',
                          style: AppTypography.display1(
                            color: AppColors.textPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 700.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        curve: Curves.easeOutCubic,
                        duration: 800.ms,
                        delay: 700.ms,
                      ),

                  const SizedBox(height: 28),

                  // Description
                  Text(
                    'Machine learning precision in wardrobe digitization and bespoke algorithmic styling.',
                    style: AppTypography.body1(
                      color: AppColors.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 1000.ms),

                  const SizedBox(height: 32),

                  // Feature pills
                  ..._buildFeatureRows()
                      .asMap()
                      .entries
                      .map(
                        (e) => e.value
                            .animate()
                            .fadeIn(
                              duration: 400.ms,
                              delay: Duration(milliseconds: 1100 + e.key * 150),
                            )
                            .slideX(
                              begin: -0.05,
                              end: 0,
                              delay: Duration(
                                  milliseconds: 1100 + e.key * 150),
                            ),
                      ),

                  const Spacer(flex: 3),

                  // CTA buttons
                  AuthPrimaryButton(
                    label: 'Get Started',
                    onPressed: () => context.go(AppRoutes.signUp),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 1600.ms)
                      .slideY(begin: 0.3, end: 0, delay: 1600.ms),

                  const SizedBox(height: 12),

                  AuthSecondaryButton(
                    label: 'Sign In',
                    onPressed: () => context.go(AppRoutes.signIn),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 1750.ms),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      'VERSION 2.4.0  •  ENTERPRISE-GRADE ENCRYPTION',
                      style: AppTypography.caption(
                        color: AppColors.textTertiary,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 2000.ms),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureRows() {
    const features = [
      ('Automated Digitization', 'High-fidelity ML classification of your collection.'),
      ('Neural Styling Engine', 'Predictive curation based on aesthetics and context.'),
    ];

    return features.map((f) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.$1,
                    style: AppTypography.body1(color: AppColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    f.$2,
                    style: AppTypography.body2(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.04)
      ..strokeWidth = 0.5;

    const step = 80.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}