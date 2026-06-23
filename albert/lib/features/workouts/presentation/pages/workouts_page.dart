import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:albert/features/workouts/presentation/pages/add_workout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  void _showAddWorkoutSheet() {
    WorkoutsController.to.resetNewRoutineDraft();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddWorkoutSheet(),
    );
  }

  void _confirmDelete(Routine routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Routine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${routine.name}"?',
            style: const TextStyle(color: AppColors.neutral60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.neutral60)),
          ),
          TextButton(
            onPressed: () {
              WorkoutsController.to.deleteRoutine(routine.id);
              Navigator.pop(context);
              Get.snackbar(
                'Routine Deleted',
                '"${routine.name}" has been deleted.',
                backgroundColor: AppColors.neutral30,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error100, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Routine routine) {
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
          // Top section of card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
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
                // Text details
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
                  onTap: () => _confirmDelete(routine),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.neutral60,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          const Divider(
            color: AppColors.neutral30,
            height: 1,
            thickness: 0.5,
          ),
          // Bottom section of card - Start session
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                WorkoutsController.to.startWorkoutSession(routine);
              },
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

  @override
  Widget build(BuildContext context) {
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
                    onTap: _showAddWorkoutSheet,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Pick a routine or build a new one.').body2(color: AppColors.neutral60),
              const SizedBox(height: 24),
              // Routines List
              Expanded(
                child: Obx(() {
                  final routines = WorkoutsController.to.routines;
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
                            onPressed: _showAddWorkoutSheet,
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
                    itemBuilder: (context, index) {
                      return _buildWorkoutCard(routines[index]);
                    },
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

