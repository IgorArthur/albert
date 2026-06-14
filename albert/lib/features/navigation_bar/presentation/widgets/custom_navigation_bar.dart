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
      const DestinationsModel(
        label: "Home",
        icon: Icons.home_outlined,
      ),
      const DestinationsModel(
        label: "Workouts",
        icon: Icons.fitness_center,
      ),
      const DestinationsModel(
        label: "Profile",
        icon: Icons.person_outline_rounded,
      ),
    ];

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GetBuilder<NavigationBarController>(
      builder: (controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D0C0C),
            border: Border(
              top: BorderSide(
                color: Color(0xFF1E1E1E),
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: 12,
            bottom: bottomPadding > 0 ? bottomPadding : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (index) {
              final destination = destinations[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    onDestinationSelected?.call(index);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0x22FF5E3A) // Premium orange with low opacity
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          destination.icon,
                          color: isSelected
                              ? const Color(0xFFFF5E3A) // Premium active orange/coral
                              : const Color(0xFF8E8E8E), // Premium inactive grey
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        destination.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF8E8E8E),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 11,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
