import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileFontSizePicker extends StatelessWidget {
  const ProfileFontSizePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileController.to;

    return Obx(() {
      final current = c.textSize.value;
      return Row(
        children: [
          _SizeOption(
            size: TextSize.small,
            label: 'Compact',
            letterFontSize: 18,
            current: current,
          ),
          const SizedBox(width: 12),
          _SizeOption(
            size: TextSize.normal,
            label: 'Standard',
            letterFontSize: 24,
            current: current,
          ),
          const SizedBox(width: 12),
          _SizeOption(
            size: TextSize.large,
            label: 'Better viz',
            letterFontSize: 30,
            current: current,
          ),
        ],
      );
    });
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.size,
    required this.label,
    required this.letterFontSize,
    required this.current,
  });

  final TextSize size;
  final String label;
  final double letterFontSize;
  final TextSize current;

  @override
  Widget build(BuildContext context) {
    final isSelected = size == current;

    return Expanded(
      child: GestureDetector(
        onTap: () => ProfileController.to.setTextSize(size),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary100.withValues(alpha: 0.12)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary100 : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: letterFontSize,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary100 : AppColors.neutral60,
                ),
              ),
              const SizedBox(height: 8),
              Text(label).caption(
                color: isSelected ? AppColors.primary100 : AppColors.neutral60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
