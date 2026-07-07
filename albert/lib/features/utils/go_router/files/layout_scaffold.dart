import 'package:albert/features/navigation_bar/presentation/widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LayoutScaffold extends StatelessWidget {
  const LayoutScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(BuildContext context, int index) {

    navigationShell.goBranch(
      index,
      // Always reset the Workouts branch to its root (routines list).
      // For other tabs, only reset when re-tapping the already-active tab.
      initialLocation: index == 1 || index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: CustomNavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
    ),
  );
}
