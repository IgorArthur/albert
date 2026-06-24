import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Horizontal emoji avatar picker row.
class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileController.to;

    return Obx(() {
      final selected = c.selectedAvatar.value;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: c.avatarOptions.map((avatar) {
          final isSelected = avatar == selected;
          return GestureDetector(
            onTap: () => c.selectAvatar(avatar),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary100.withValues(alpha: 0.15)
                    : AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary100 : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                avatar,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
