import 'package:albert/features/home/presentation/pages/home_page.dart';
import 'package:albert/features/workouts/workouts.dart';
import 'package:albert/features/profile/profile.dart';
import 'package:albert/features/utils/go_router/files/layout_scaffold.dart';
import 'package:albert/features/workouts/presentation/pages/session_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.homePage,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          LayoutScaffold(navigationShell: navigationShell),
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
  ],
);

class Routes {
  Routes._();
  static const String homePage = '/';
  static const String workoutsPage = '/workouts';
  static const String profilePage = '/profile';
  static const String sessionPage = '/session';
}
