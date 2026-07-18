import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/workout.dart';

abstract class WorkoutRepository {
  Future<Either<Failure, List<Workout>>> getWorkouts();
  Future<Either<Failure, void>> addWorkout(Workout workout);
  Future<Either<Failure, void>> deleteWorkout(String id);
}
