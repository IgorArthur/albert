import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:albert/features/workouts/presentation/widgets/workout_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutsController.to;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header
              const Text('LIBRARY').overline(color: AppColors.primary100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Workouts').display(color: Colors.white),
                  GestureDetector(
                    onTap: () => controller.showAddSheet(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Pick a routine or build a new one.').body2(color: AppColors.neutral60),
              const SizedBox(height: 24),
              // Routines list
              Expanded(
                child: Obx(() {
                  final routines = controller.routines;
                  if (routines.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.neutral60,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text('No workouts added yet.').subtitle2(color: AppColors.neutral60),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => controller.showAddSheet(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Build new routine'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary100,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: routines.length,
                    itemBuilder: (context, index) => WorkoutCard(routine: routines[index]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
