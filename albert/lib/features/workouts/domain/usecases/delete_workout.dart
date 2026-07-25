import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/workout_repository.dart';

class DeleteWorkout implements UseCase<void, DeleteWorkoutParams> {
  final WorkoutRepository repository;
  DeleteWorkout(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteWorkoutParams params) => repository.deleteWorkout(params.id);
}

class DeleteWorkoutParams {
  final String id;
  const DeleteWorkoutParams({required this.id});
}
