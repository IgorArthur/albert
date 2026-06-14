import 'package:albert/features/home/presentation/pages/home_page.dart';
import 'package:albert/features/utils/go_router/files/layout_scaffold.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
              builder: (context, state) => HomePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class Routes {
  Routes._();
  static const String homePage = '/';
}
