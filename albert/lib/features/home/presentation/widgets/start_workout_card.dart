import 'package:albert/features/home/presentation/getx/home_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

class StartWorkoutCard extends StatelessWidget {
  const StartWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.to;

    return Expanded(
      child: GestureDetector(
        onTap: controller.startNextWorkout,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGradientStart, AppColors.primary100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.fitness_center_rounded,
                color: Colors.black.withValues(alpha: 0.7),
                size: 28,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("START NOW").overline(color: Colors.black.withValues(alpha: 0.6)),
                  const SizedBox(height: 4),
                  Text(
                    "🔥 ${controller.nextWorkoutName}",
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
