import 'package:flutter/material.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/fonts/app_fonts.dart';
import '../../domain/entities/workout.dart';

class WorkoutTile extends StatelessWidget {
  final Workout workout;
  const WorkoutTile({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Icon bubble or Photo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceLight : Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: workout.photoUrl != null && workout.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      workout.photoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.primary100,
                        size: 22,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary100,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.exerciseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).subtitle1(),
                const SizedBox(height: 4),
                Text(
                  '${workout.sets} sets · ${workout.reps} reps · ${workout.weightKg} kg',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).body2(color: AppColors.neutral60),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Date
          Text(
            '${workout.date.day}/${workout.date.month}',
          ).captionBold(color: AppColors.neutral60),
        ],
      ),
    );
  }
}
