import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:albert/features/workouts/presentation/widgets/exercise_number_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExerciseDraftCard extends StatefulWidget {
  const ExerciseDraftCard({
    super.key,
    required this.index,
    required this.exercise,
  });

  final int index;
  final Exercise exercise;

  @override
  State<ExerciseDraftCard> createState() => _ExerciseDraftCardState();
}

class _ExerciseDraftCardState extends State<ExerciseDraftCard> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutsController.to;
    final exercise = widget.exercise;

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
                (widget.index + 1).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppColors.primary100,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Exercise name',
                    hintStyle: TextStyle(color: AppColors.neutral60),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => exercise.name = val,
                ),
              ),
              Obx(() => controller.newRoutineExercises.length > 1
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error100),
                      onPressed: () => controller.removeExerciseFromDraft(widget.index),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const Divider(color: AppColors.neutral30, height: 16, thickness: 0.5),
          const SizedBox(height: 8),
          Row(
            children: [
              ExerciseNumberInput(
                label: 'SETS',
                initialValue: exercise.sets.toString(),
                onChanged: (val) => exercise.sets = int.tryParse(val) ?? 0,
              ),
              const SizedBox(width: 12),
              ExerciseNumberInput(
                label: 'REPS',
                initialValue: exercise.reps.toString(),
                onChanged: (val) => exercise.reps = int.tryParse(val) ?? 0,
              ),
              const SizedBox(width: 12),
              ExerciseNumberInput(
                label: 'KG',
                initialValue: exercise.kg % 1 == 0
                    ? exercise.kg.toInt().toString()
                    : exercise.kg.toString(),
                onChanged: (val) => exercise.kg = double.tryParse(val) ?? 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
