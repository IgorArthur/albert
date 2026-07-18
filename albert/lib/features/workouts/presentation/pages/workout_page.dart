import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/fonts/app_fonts.dart';
import '../controllers/workout_controller.dart';
import '../widgets/workout_tile.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutController>();
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.0, topPadding + 24.0, 20.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('workouts_library'.tr.toUpperCase()).overline(color: AppColors.primary100),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('workouts_title'.tr).display(),
                GestureDetector(
                  onTap: () => controller.loadWorkouts(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceLight : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: isDark ? Colors.white : Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Logged Workouts history'.tr).body1(color: AppColors.neutral60),
            const SizedBox(height: 32),
            // Workouts List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary100),
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Text(controller.errorMessage.value!).subtitle2(color: AppColors.error100),
                  );
                }

                final list = controller.workouts;
                if (list.isEmpty) {
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
                        Text('No workouts logged yet.').subtitle2(color: AppColors.neutral60),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) => WorkoutTile(workout: list[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
