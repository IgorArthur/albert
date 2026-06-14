import 'package:albert/features/navigation_bar/data/destinations_model.dart';
import 'package:albert/features/navigation_bar/presentation/widgets/getx/navigation_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    this.onDestinationSelected,
    required this.selectedIndex,
    super.key,
  });

  final Function(int)? onDestinationSelected;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      DestinationsModel(label: "Home", icon: Icons.dashboard_outlined),
      DestinationsModel(label: "Workout", icon: Icons.show_chart_outlined),
      DestinationsModel(label: "Profile", icon: Icons.settings_outlined),
    ];

    return GetBuilder<NavigationBarController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white, width: 1)),
            color: Colors.red,
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          child: NavigationBar(
            elevation: 8,
            backgroundColor: Colors.black,
            indicatorColor: Colors.blue,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            height: 60,
            selectedIndex: selectedIndex,
            destinations: destinations
                .map(
                  (destination) => NavigationDestination(
                    icon: Icon(destination.icon),
                    label: destination.label,
                  ),
                )
                .toList(),
            onDestinationSelected: onDestinationSelected,
          ),
        );
      },
    );
  }
}
