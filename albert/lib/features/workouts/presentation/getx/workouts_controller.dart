import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
import 'package:albert/features/workouts/presentation/pages/add_workout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutsController extends GetxController {
  static WorkoutsController get to => Get.find();

  final RxList<Routine> routines = <Routine>[].obs;

  // New/edit routine builder draft state
  final TextEditingController newRoutineNameController = TextEditingController();
  final RxString newRoutineIcon = '🔥'.obs;
  final RxList<Exercise> newRoutineExercises = <Exercise>[].obs;
  final List<String> draftIcons = ['🔥', '⚡', '🦵', '💪', '🏋️', '🥊', '🏃', '🧘'];

  // Tracks the id of the routine being edited (null = creating new)
  String? editingRoutineId;

  // ─── Getters ──────────────────────────────────────────────────────────────

  bool get isEditingMode => editingRoutineId != null;

  String get sheetTitle => isEditingMode ? 'Edit routine' : 'New routine';

  String get saveButtonLabel => isEditingMode ? 'Save changes' : 'Save routine';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadRoutines();
  }

  @override
  void onClose() {
    newRoutineNameController.dispose();
    super.onClose();
  }

  // ─── Sheet actions ────────────────────────────────────────────────────────

  void showAddSheet(BuildContext context) {
    resetNewRoutineDraft();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWorkoutSheet(),
    );
  }

  void showEditSheet(BuildContext context, Routine routine) {
    loadRoutineForEdit(routine);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWorkoutSheet(),
    );
  }

  // ─── Delete confirmation ──────────────────────────────────────────────────

  void confirmDelete(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Routine',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${routine.name}"?',
          style: const TextStyle(color: AppColors.neutral60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.neutral60)),
          ),
          TextButton(
            onPressed: () {
              deleteRoutine(routine.id);
              Navigator.pop(ctx);
              Get.snackbar(
                'Routine Deleted',
                '"${routine.name}" has been deleted.',
                backgroundColor: AppColors.neutral30,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error100, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Draft management ─────────────────────────────────────────────────────

  void resetNewRoutineDraft() {
    editingRoutineId = null;
    newRoutineNameController.clear();
    newRoutineIcon.value = '🔥';
    newRoutineExercises.assignAll([
      Exercise(name: '', sets: 3, reps: 10, kg: 0),
    ]);
  }

  void loadRoutineForEdit(Routine routine) {
    editingRoutineId = routine.id;
    newRoutineNameController.text = routine.name;
    newRoutineIcon.value = routine.icon;
    newRoutineExercises.assignAll(
      routine.exercises
          .map((e) => Exercise(name: e.name, sets: e.sets, reps: e.reps, kg: e.kg))
          .toList(),
    );
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

  // ─── Save / Update ────────────────────────────────────────────────────────

  bool saveRoutine() {
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
      return false;
    }

    if (isEditingMode) {
      _updateRoutine(editingRoutineId!, name);
    } else {
      final newRoutine = Routine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        icon: newRoutineIcon.value,
        createdAt: DateTime.now(),
        exercises: List<Exercise>.from(newRoutineExercises),
      );
      addRoutine(newRoutine);
    }
    return true;
  }

  void _updateRoutine(String id, String name) {
    final index = routines.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final updated = Routine(
      id: id,
      name: name,
      icon: newRoutineIcon.value,
      createdAt: routines[index].createdAt,
      exercises: List<Exercise>.from(newRoutineExercises),
    );

    boxRoutines.put(id, updated);
    routines[index] = updated;
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  String? validateRoutine(String name, List<Exercise> exercises) {
    if (name.trim().isEmpty) return 'Please enter a routine name.';
    if (exercises.isEmpty) return 'Please add at least one exercise.';
    for (var i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      if (exercise.name.trim().isEmpty) return 'Please enter a name for Exercise ${i + 1}.';
      if (exercise.sets <= 0) return 'Sets for "${exercise.name}" must be greater than 0.';
      if (exercise.reps <= 0) return 'Reps for "${exercise.name}" must be greater than 0.';
      if (exercise.kg < 0) return 'Weight for "${exercise.name}" cannot be negative.';
    }
    return null;
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  void addRoutine(Routine routine) {
    boxRoutines.put(routine.id, routine);
    routines.add(routine);
  }

  void deleteRoutine(String id) {
    boxRoutines.delete(id);
    routines.removeWhere((r) => r.id == id);
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  void startWorkoutSession(Routine routine) {
    final clonedExercises = routine.exercises
        .map((e) => Exercise(name: e.name, sets: e.sets, reps: e.reps, kg: e.kg))
        .toList();

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

  // ─── Load ─────────────────────────────────────────────────────────────────

  void _loadRoutines() {
    routines.assignAll(boxRoutines.values.toList().cast<Routine>());
  }
}
