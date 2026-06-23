import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/models/workout.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddWorkoutSheet extends StatefulWidget {
  const AddWorkoutSheet({super.key});

  @override
  State<AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  final _nameController = TextEditingController();
  String _selectedIcon = '🔥';
  final List<ExerciseModel> _exercises = [
    ExerciseModel(name: ''),
  ];

  final List<String> _icons = ['🔥', '⚡', '🦵', '💪', '🏋️', '🥊', '🏃', '🧘'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveRoutine() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a routine name.',
        backgroundColor: AppColors.error100,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_exercises.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please add at least one exercise.',
        backgroundColor: AppColors.error100,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    for (var i = 0; i < _exercises.length; i++) {
      if (_exercises[i].name.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter a name for Exercise ${i + 1}.',
          backgroundColor: AppColors.error100,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (_exercises[i].sets <= 0) {
        Get.snackbar(
          'Validation Error',
          'Sets for "${_exercises[i].name}" must be greater than 0.',
          backgroundColor: AppColors.error100,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (_exercises[i].reps <= 0) {
        Get.snackbar(
          'Validation Error',
          'Reps for "${_exercises[i].name}" must be greater than 0.',
          backgroundColor: AppColors.error100,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final newRoutine = WorkoutRoutine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: _selectedIcon,
      exercises: _exercises,
    );

    WorkoutsController.to.addRoutine(newRoutine);
    Get.back();
  }

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

  Widget _buildExerciseCard(int index, ExerciseModel exercise) {
    return Container(
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
              if (_exercises.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error100),
                  onPressed: () {
                    setState(() {
                      _exercises.removeAt(index);
                    });
                  },
                ),
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
                initialValue: exercise.weight % 1 == 0
                    ? exercise.weight.toInt().toString()
                    : exercise.weight.toString(),
                onChanged: (val) {
                  exercise.weight = double.tryParse(val) ?? 0;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _icons.map((icon) {
          final isSelected = _selectedIcon == icon;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = icon;
              });
            },
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
  }

  @override
  Widget build(BuildContext context) {
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
                onTap: () => Get.back(),
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
                      controller: _nameController,
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
                  _buildIconSelector(),
                  const SizedBox(height: 24),
                  // EXERCISES Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('EXERCISES').overline(color: AppColors.neutral60),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _exercises.add(ExerciseModel(name: ''));
                          });
                        },
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
                  ...List.generate(_exercises.length, (index) {
                    return _buildExerciseCard(index, _exercises[index]);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Save routine Button
          ElevatedButton(
            onPressed: _saveRoutine,
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
