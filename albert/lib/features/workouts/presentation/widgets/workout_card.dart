import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutsController.to;
    final exercisesText = routine.exercises.map((e) => e.name).join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral30, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top section — tap to edit
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.showEditSheet(context, routine),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon bubble
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        routine.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(routine.name).subtitle1(color: Colors.white),
                          const SizedBox(height: 4),
                          Text(
                            exercisesText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).body2(color: AppColors.neutral60),
                          const SizedBox(height: 6),
                          Text(
                            '${routine.exercises.length} exercises · ~${routine.totalSets} sets',
                          ).captionBold(color: AppColors.primary100),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    GestureDetector(
                      onTap: () => controller.confirmDelete(context, routine),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.neutral60,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Divider
          const Divider(color: AppColors.neutral30, height: 1, thickness: 0.5),
          // Bottom section — start session
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.startWorkoutSession(routine),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.primary100,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text('Start session').body2Bold(color: AppColors.primary100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
