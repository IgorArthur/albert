import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({
    required this.name,
    required this.exercisesCount,
    required this.icon,
    this.onTap,
    super.key,
  });

  final String name;
  final int exercisesCount;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon / Emoji
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const Spacer(),
            // Title
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text("$exercisesCount exercises").caption(color: AppColors.neutral60),
          ],
        ),
      ),
    );
  }
}
