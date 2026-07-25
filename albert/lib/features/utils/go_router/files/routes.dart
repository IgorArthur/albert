import 'package:albert/features/home/presentation/pages/home_page.dart';
import 'package:albert/features/workouts/workouts.dart';
import 'package:albert/features/profile/profile.dart';
import 'package:albert/features/progress/progress.dart';
import 'package:albert/features/login/login.dart';
import 'package:albert/features/utils/go_router/files/layout_scaffold.dart';
import 'package:albert/features/workouts/presentation/pages/session_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/coach/presentation/pages/coach_page.dart';
import 'package:albert/features/coach/presentation/bindings/coach_binding.dart';
import 'package:albert/features/workouts/presentation/pages/workout_page.dart';
import 'package:albert/features/workouts/presentation/bindings/workout_binding.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: boxAuth.get('user') != null ? Routes.homePage : Routes.loginPage,
  routes: [
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, navigationShell) => CustomTransitionPage(
        key: state.pageKey,
        child: LayoutScaffold(navigationShell: navigationShell),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homePage,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.workoutsPage,
              builder: (context, state) => const WorkoutsPage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.progressPage,
              builder: (context, state) => const ProgressPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profilePage,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    // Full-screen session route — outside the shell (no bottom nav bar)
    GoRoute(
      path: Routes.sessionPage,
      builder: (context, state) => const SessionPage(),
    ),
    // Login route — outside the shell
    GoRoute(
      path: Routes.loginPage,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPage(),
      ),
    ),
    // Coach AI route
    GoRoute(
      path: Routes.coachPage,
      builder: (context, state) {
        CoachBinding().dependencies();
        return const CoachPage();
      },
    ),
    // Clean Architecture Workout History list route
    GoRoute(
      path: Routes.workoutHistoryPage,
      builder: (context, state) {
        WorkoutBinding().dependencies();
        return const WorkoutPage();
      },
    ),
  ],
);

class Routes {
  Routes._();
  static const String homePage = '/';
  static const String workoutsPage = '/workouts';
  static const String profilePage = '/profile';
  static const String progressPage = '/progress';
  static const String sessionPage = '/session';
  static const String loginPage = '/login';
  static const String coachPage = '/coach';
  static const String workoutHistoryPage = '/workout-history';
}
