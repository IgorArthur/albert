import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

class AddWorkout implements UseCase<void, AddWorkoutParams> {
  final WorkoutRepository repository;
  AddWorkout(this.repository);

  @override
  Future<Either<Failure, void>> call(AddWorkoutParams params) => repository.addWorkout(params.workout);
}

class AddWorkoutParams {
  final Workout workout;
  const AddWorkoutParams({required this.workout});
}
