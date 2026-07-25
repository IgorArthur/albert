import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_model.dart';

abstract class WorkoutLocalDataSource {
  Future<List<WorkoutModel>> getCachedWorkouts();
  Future<void> cacheWorkouts(List<WorkoutModel> workouts);
  Future<void> addWorkout(WorkoutModel workout);
  Future<void> deleteWorkout(String id);
}

class WorkoutLocalDataSourceImpl implements WorkoutLocalDataSource {
  final Box<WorkoutModel> box;
  WorkoutLocalDataSourceImpl(this.box);

  @override
  Future<List<WorkoutModel>> getCachedWorkouts() async {
    try {
      return box.values.toList();
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheWorkouts(List<WorkoutModel> workouts) async {
    await box.clear();
    await box.putAll({for (final w in workouts) w.id: w});
  }

  @override
  Future<void> addWorkout(WorkoutModel workout) async => box.put(workout.id, workout);

  @override
  Future<void> deleteWorkout(String id) async => box.delete(id);
}
