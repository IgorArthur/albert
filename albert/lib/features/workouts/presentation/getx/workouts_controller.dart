import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutsController extends GetxController {
  static WorkoutsController get to => Get.find();

  final RxList<Routine> routines = <Routine>[].obs;

  // New routine builder draft state
  final TextEditingController newRoutineNameController = TextEditingController();
  final RxString newRoutineIcon = '🔥'.obs;
  final RxList<Exercise> newRoutineExercises = <Exercise>[].obs;
  final List<String> draftIcons = ['🔥', '⚡', '🦵', '💪', '🏋️', '🥊', '🏃', '🧘'];

  @override
  void onInit() {
    super.onInit();
    _loadOrSeedRoutines();
  }

  @override
  void onClose() {
    newRoutineNameController.dispose();
    super.onClose();
  }

  void _loadOrSeedRoutines() {
    if (boxRoutines.isEmpty) {
      final initial = [
        Routine(
          id: '1',
          name: 'Push Day',
          icon: '🔥',
          createdAt: DateTime.now(),
          exercises: [
            Exercise(name: 'Bench Press', sets: 3, reps: 10, kg: 0),
            Exercise(name: 'Overhead Press', sets: 3, reps: 10, kg: 0),
            Exercise(name: 'Incline Dumbbell Press', sets: 3, reps: 10, kg: 0),
            Exercise(name: 'Triceps Pushdown', sets: 4, reps: 10, kg: 0),
          ],
        ),
        Routine(
          id: '2',
          name: 'Pull Day',
          icon: '⚡',
          createdAt: DateTime.now(),
          exercises: [
            Exercise(name: 'Deadlift', sets: 3, reps: 10, kg: 0),
            Exercise(name: 'Pull-ups', sets: 3, reps: 10, kg: 0),
            Exercise(name: 'Barbell Row', sets: 4, reps: 10, kg: 0),
            Exercise(name: 'Bicep Curl', sets: 4, reps: 10, kg: 0),
          ],
        ),
        Routine(
          id: '3',
          name: 'Leg Day',
          icon: '🦵',
          createdAt: DateTime.now(),
          exercises: [
            Exercise(name: 'Back Squat', sets: 3, reps: 10, kg: 0),
            Exercise(name: 'Romanian Deadlift', sets: 3, reps: 10, kg: 0),
            Exercise(name: 'Walking Lunges', sets: 4, reps: 10, kg: 0),
            Exercise(name: 'Calf Raise', sets: 4, reps: 10, kg: 0),
          ],
        ),
      ];

      for (var routine in initial) {
        boxRoutines.put(routine.id, routine);
      }
    }

    routines.assignAll(boxRoutines.values.toList().cast<Routine>());
  }

  void resetNewRoutineDraft() {
    newRoutineNameController.clear();
    newRoutineIcon.value = '🔥';
    newRoutineExercises.assignAll([
      Exercise(name: '', sets: 3, reps: 10, kg: 0),
    ]);
  }

  void addExerciseToDraft() {
    newRoutineExercises.add(Exercise(name: '', sets: 3, reps: 10, kg: 0));
  }

  void removeExerciseFromDraft(int index) {
    if (newRoutineExercises.length > 1) {
      newRoutineExercises.removeAt(index);
    }
  }

  void selectIconForDraft(String icon) {
    newRoutineIcon.value = icon;
  }

  void saveRoutine() {
    final name = newRoutineNameController.text.trim();
    final validationError = validateRoutine(name, newRoutineExercises);
    if (validationError != null) {
      Get.snackbar(
        'Validation Error',
        validationError,
        backgroundColor: AppColors.error100,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newRoutine = Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: newRoutineIcon.value,
      createdAt: DateTime.now(),
      exercises: List<Exercise>.from(newRoutineExercises),
    );

    addRoutine(newRoutine);
    Get.back();
  }

  String? validateRoutine(String name, List<Exercise> exercises) {
    if (name.trim().isEmpty) {
      return 'Please enter a routine name.';
    }
    if (exercises.isEmpty) {
      return 'Please add at least one exercise.';
    }
    for (var i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      if (exercise.name.trim().isEmpty) {
        return 'Please enter a name for Exercise ${i + 1}.';
      }
      if (exercise.sets <= 0) {
        return 'Sets for "${exercise.name}" must be greater than 0.';
      }
      if (exercise.reps <= 0) {
        return 'Reps for "${exercise.name}" must be greater than 0.';
      }
      if (exercise.kg < 0) {
        return 'Weight for "${exercise.name}" cannot be negative.';
      }
    }
    return null;
  }

  void addRoutine(Routine routine) {
    boxRoutines.put(routine.id, routine);
    routines.add(routine);
  }

  void deleteRoutine(String id) {
    boxRoutines.delete(id);
    routines.removeWhere((r) => r.id == id);
  }

  void startWorkoutSession(Routine routine) {
    final clonedExercises = routine.exercises.map((e) => Exercise(
      name: e.name,
      sets: e.sets,
      reps: e.reps,
      kg: e.kg,
    )).toList();

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineId: routine.id,
      routineName: routine.name,
      startedAt: DateTime.now(),
      exercises: clonedExercises,
    );

    boxWorkoutSessions.put(session.id, session);

    Get.snackbar(
      'Workout Session',
      'Started "${routine.name}" session! Logged to Hive.',
      backgroundColor: AppColors.primary100.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

