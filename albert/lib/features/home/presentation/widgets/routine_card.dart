import 'package:albert/features/home/presentation/getx/home_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:flutter/material.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HomeController.to.onRoutineTap(routine),
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
            Text(
              routine.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const Spacer(),
            Text(
              routine.name,
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
            Text("${routine.exercises.length} exercises").caption(color: AppColors.neutral60),
          ],
        ),
      ),
    );
  }
}
