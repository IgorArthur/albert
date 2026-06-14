import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initHiveAndBoxes() async {
  await Hive.initFlutter();
  _registerHiveAdapters();
  await _openHiveBoxes();
}

void _registerHiveAdapters() {
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(RoutineAdapter());
  Hive.registerAdapter(WorkoutSessionAdapter());
}

Future<void> _openHiveBoxes() async {
  boxExercises = await Hive.openBox<Exercise>('exerciseBox');
  boxRoutines = await Hive.openBox<Routine>('routineBox');
  boxWorkoutSessions = await Hive.openBox<WorkoutSession>('workoutSessionBox');
}