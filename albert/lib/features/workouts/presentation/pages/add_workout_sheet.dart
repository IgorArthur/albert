import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddWorkoutSheet extends StatelessWidget {
  const AddWorkoutSheet({super.key});

  Widget _buildNumberInput({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label).overline(color: AppColors.neutral60),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.neutral0,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neutral30, width: 0.5),
            ),
            child: TextFormField(
              initialValue: initialValue,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index, Exercise exercise, WorkoutsController controller) {
    return Container(
      key: ValueKey(exercise.hashCode),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral30, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                (index + 1).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppColors.primary100,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: exercise.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Exercise name',
                    hintStyle: TextStyle(color: AppColors.neutral60),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    exercise.name = val;
                  },
                ),
              ),
              Obx(() => controller.newRoutineExercises.length > 1
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error100),
                      onPressed: () => controller.removeExerciseFromDraft(index),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const Divider(color: AppColors.neutral30, height: 16, thickness: 0.5),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildNumberInput(
                label: 'SETS',
                initialValue: exercise.sets.toString(),
                onChanged: (val) {
                  exercise.sets = int.tryParse(val) ?? 0;
                },
              ),
              const SizedBox(width: 12),
              _buildNumberInput(
                label: 'REPS',
                initialValue: exercise.reps.toString(),
                onChanged: (val) {
                  exercise.reps = int.tryParse(val) ?? 0;
                },
              ),
              const SizedBox(width: 12),
              _buildNumberInput(
                label: 'KG',
                initialValue: exercise.kg % 1 == 0
                    ? exercise.kg.toInt().toString()
                    : exercise.kg.toString(),
                onChanged: (val) {
                  exercise.kg = double.tryParse(val) ?? 0;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector(WorkoutsController controller) {
    return Obx(() {
      final selectedIcon = controller.newRoutineIcon.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: controller.draftIcons.map((icon) {
            final isSelected = selectedIcon == icon;
            return GestureDetector(
              onTap: () => controller.selectIconForDraft(icon),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary100 : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.neutral30,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutsController.to;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: bottomPadding > 0 ? bottomPadding + 16 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New routine',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  )),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Scrollable inputs
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // NAME Section
                  const Text('NAME').overline(color: AppColors.neutral60),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral30, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: controller.newRoutineNameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Upper body burner',
                        hintStyle: TextStyle(color: AppColors.neutral60),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ICON Section
                  const Text('ICON').overline(color: AppColors.neutral60),
                  const SizedBox(height: 8),
                  _buildIconSelector(controller),
                  const SizedBox(height: 24),
                  // EXERCISES Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('EXERCISES').overline(color: AppColors.neutral60),
                      GestureDetector(
                        onTap: () => controller.addExerciseToDraft(),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: AppColors.primary100, size: 16),
                            const SizedBox(width: 4),
                            const Text('Add').overline(color: AppColors.primary100),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Exercises Cards list
                  Obx(() {
                    final exercises = controller.newRoutineExercises;
                    return Column(
                      children: List.generate(exercises.length, (index) {
                        return _buildExerciseCard(index, exercises[index], controller);
                      }),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Save routine Button
          ElevatedButton(
            onPressed: () => controller.saveRoutine(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F4221), // Rust orange button
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save routine',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
