import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens//onboarding_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/style_quiz_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/closet/presentation/screens/closet_screen.dart';
import '../../features/closet/presentation/screens/item_detail_screen.dart';
import '../../features/closet/presentation/screens/add_item_screen.dart';
import '../../features/ai_stylist/presentation/screen/ai_stylist_screen.dart';
import '../../features/ai_stylist/presentation/screen//outfit_suggestion_screen.dart';
import '../../features/outfits/presentation/screens/outfits_screen.dart';
import '../../features/outfits/presentation/screens/outfit_builder_screen.dart';
import '../../features/outfits/presentation/screens//calender_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../widgets/main_shell.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String styleQuiz = '/style-quiz';
  static const String home = '/';
  static const String closet = '/closet';
  static const String itemDetail = '/closet/item/:id';
  static const String addItem = '/closet/add';
  static const String aiStylist = '/stylist';
  static const String outfitSuggestion = '/stylist/outfit';
  static const String outfits = '/outfits';
  static const String outfitBuilder = '/outfits/builder';
  static const String calendar = '/outfits/calendar';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
  static const String settings = '/profile/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final isOnboarding = state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/sign');

      if (!isAuthenticated && !isOnboarding) {
        return AppRoutes.onboarding;
      }
      if (isAuthenticated && isOnboarding) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      // Onboarding / Auth
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _buildFadePage(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (context, state) => _buildSlidePage(
          state,
          const SignInScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (context, state) => _buildSlidePage(
          state,
          const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.styleQuiz,
        pageBuilder: (context, state) => _buildSlidePage(
          state,
          const StyleQuizScreen(),
        ),
      ),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            redirect: (_, __) => AppRoutes.closet,
          ),
          GoRoute(
            path: AppRoutes.closet,
            pageBuilder: (context, state) => _buildFadePage(
              state,
              const ClosetScreen(),
            ),
            routes: [
              GoRoute(
                path: 'item/:id',
                pageBuilder: (context, state) => _buildSlidePage(
                  state,
                  ItemDetailScreen(itemId: state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'add',
                pageBuilder: (context, state) => _buildModalPage(
                  state,
                  const AddItemScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.aiStylist,
            pageBuilder: (context, state) => _buildFadePage(
              state,
              const AiStylistScreen(),
            ),
            routes: [
              GoRoute(
                path: 'outfit',
                pageBuilder: (context, state) {
                  final itemId = state.uri.queryParameters['itemId'];
                  return _buildSlidePage(
                    state,
                    OutfitSuggestionScreen(baseItemId: itemId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.outfits,
            pageBuilder: (context, state) => _buildFadePage(
              state,
              const OutfitsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'builder',
                pageBuilder: (context, state) => _buildSlidePage(
                  state,
                  const OutfitBuilderScreen(),
                ),
              ),
              GoRoute(
                path: 'calendar',
                pageBuilder: (context, state) => _buildSlidePage(
                  state,
                  const CalendarScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.analytics,
            pageBuilder: (context, state) => _buildFadePage(
              state,
              const AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _buildFadePage(
              state,
              const ProfileScreen(),
            ),
            routes: [
              GoRoute(
                path: 'settings',
                pageBuilder: (context, state) => _buildSlidePage(
                  state,
                  const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<T> _buildFadePage<T>(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

CustomTransitionPage<T> _buildSlidePage<T>(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

CustomTransitionPage<T> _buildModalPage<T>(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}