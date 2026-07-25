import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../entities/workout_evaluation.dart';
import '../repositories/coach_repository.dart';

class EvaluateWorkout implements UseCase<WorkoutEvaluation, EvaluateWorkoutParams> {
  final CoachRepository repository;
  EvaluateWorkout(this.repository);

  @override
  Future<Either<Failure, WorkoutEvaluation>> call(EvaluateWorkoutParams params) =>
      repository.evaluateWorkout(params.workout);
}

class EvaluateWorkoutParams {
  final Workout workout;
  const EvaluateWorkoutParams({required this.workout});
}
