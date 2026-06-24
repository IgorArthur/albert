import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoutineIconSelector extends StatelessWidget {
  const RoutineIconSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutsController.to;

    return Obx(() {
      final selectedIcon = controller.newRoutineIcon.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: controller.draftIcons.map((icon) {
            final isSelected = selectedIcon == icon;
            return GestureDetector(
              onTap: () => controller.selectIconForDraft(icon),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary100 : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.neutral30,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
