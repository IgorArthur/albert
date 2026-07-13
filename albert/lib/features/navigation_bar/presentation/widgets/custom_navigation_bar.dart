import 'package:albert/features/navigation_bar/data/destinations_model.dart';
import 'package:albert/features/navigation_bar/presentation/widgets/getx/navigation_bar_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
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
      DestinationsModel(
        label: 'nav_home'.tr,
        icon: Icons.home_outlined,
      ),
      DestinationsModel(
        label: 'nav_workouts'.tr,
        icon: Icons.fitness_center,
      ),
      DestinationsModel(
        label: 'nav_progress'.tr,
        icon: Icons.trending_up,
      ),
      DestinationsModel(
        label: 'nav_profile'.tr,
        icon: Icons.person_outline_rounded,
      ),
    ];

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GetBuilder<NavigationBarController>(
      builder: (controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.neutral0,
            border: Border(
              top: BorderSide(
                color: AppColors.neutral30,
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
                              ? AppColors.primary100.withValues(alpha: 0.13)
                              : AppColors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          destination.icon,
                          color: isSelected
                              ? AppColors.primary100
                              : AppColors.neutral60,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      isSelected
                          ? Text(destination.label).captionBold(color: AppColors.neutral100)
                          : Text(destination.label).caption(color: AppColors.neutral60),
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
