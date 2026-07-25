import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/utils/utils.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:albert/features/workouts/presentation/widgets/workout_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutsController.to;
    controller.handlePendingEditSheet(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshAppData,
        color: AppColors.primary100,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(20.0, topPadding + 24.0, 20.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('workouts_library'.tr).overline(color: AppColors.primary100),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('workouts_title'.tr).display(),
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
              const SizedBox(height: 6),
              Text('workouts_subtitle'.tr).body1(color: AppColors.neutral60),
              const SizedBox(height: 32),
              // Routines list
              Obx(() {
                final routines = controller.routines;
                if (routines.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.neutral60,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text('workouts_empty'.tr)
                              .subtitle2(color: AppColors.neutral60),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => controller.showAddSheet(context),
                            icon: const Icon(Icons.add),
                            label: Text('workouts_build_new'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary100,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24.0),
                  itemCount: routines.length,
                  itemBuilder: (context, index) =>
                      WorkoutCard(routine: routines[index]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
