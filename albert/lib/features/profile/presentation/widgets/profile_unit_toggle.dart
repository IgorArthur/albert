import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Metric / Imperial toggle pair.
class ProfileUnitToggle extends StatelessWidget {
  const ProfileUnitToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileController.to;

    return Obx(() {
      final metric = c.isMetric.value;
      return Row(
        children: [
          _UnitButton(
            label: 'Metric (Kg / Cm)',
            selected: metric,
            onTap: () => c.toggleUnit(true),
          ),
          const SizedBox(width: 12),
          _UnitButton(
            label: 'Imperial (Lb / In)',
            selected: !metric,
            onTap: () => c.toggleUnit(false),
          ),
        ],
      );
    });
  }
}

class _UnitButton extends StatelessWidget {
  const _UnitButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary100.withValues(alpha: 0.12) : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.primary100 : AppColors.neutral30,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(label).captionBold(
            color: selected ? AppColors.primary100 : AppColors.neutral60,
          ),
        ),
      ),
    );
  }
}
