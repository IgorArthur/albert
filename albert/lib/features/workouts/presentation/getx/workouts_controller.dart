import 'package:albert/features/workouts/models/workout.dart';
import 'package:get/get.dart';

class WorkoutsController extends GetxController {
  static WorkoutsController get to => Get.find();

  final RxList<WorkoutRoutine> routines = <WorkoutRoutine>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedInitialRoutines();
  }

  void _seedInitialRoutines() {
    routines.assignAll([
      WorkoutRoutine(
        id: '1',
        name: 'Push Day',
        icon: '🔥',
        exercises: [
          ExerciseModel(name: 'Bench Press', sets: 3, reps: 10, weight: 0),
          ExerciseModel(name: 'Overhead Press', sets: 3, reps: 10, weight: 0),
          ExerciseModel(name: 'Incline Dumbbell Press', sets: 3, reps: 10, weight: 0),
          ExerciseModel(name: 'Triceps Pushdown', sets: 4, reps: 10, weight: 0),
        ],
      ),
      WorkoutRoutine(
        id: '2',
        name: 'Pull Day',
        icon: '⚡',
        exercises: [
          ExerciseModel(name: 'Deadlift', sets: 3, reps: 10, weight: 0),
          ExerciseModel(name: 'Pull-ups', sets: 3, reps: 10, weight: 0),
          ExerciseModel(name: 'Barbell Row', sets: 4, reps: 10, weight: 0),
          ExerciseModel(name: 'Bicep Curl', sets: 4, reps: 10, weight: 0),
        ],
      ),
      WorkoutRoutine(
        id: '3',
        name: 'Leg Day',
        icon: '🦵',
        exercises: [
          ExerciseModel(name: 'Back Squat', sets: 3, reps: 10, weight: 0),
          ExerciseModel(name: 'Romanian Deadlift', sets: 3, reps: 10, weight: 0),
          ExerciseModel(name: 'Walking Lunges', sets: 4, reps: 10, weight: 0),
          ExerciseModel(name: 'Calf Raise', sets: 4, reps: 10, weight: 0),
        ],
      ),
    ]);
  }

  void addRoutine(WorkoutRoutine routine) {
    routines.add(routine);
  }

  void deleteRoutine(String id) {
    routines.removeWhere((r) => r.id == id);
  }
}

