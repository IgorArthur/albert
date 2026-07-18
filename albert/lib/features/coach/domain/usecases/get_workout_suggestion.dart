import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../entities/workout_suggestion.dart';
import '../repositories/coach_repository.dart';

class GetWorkoutSuggestion implements UseCase<WorkoutSuggestion, GetWorkoutSuggestionParams> {
  final CoachRepository repository;
  GetWorkoutSuggestion(this.repository);

  @override
  Future<Either<Failure, WorkoutSuggestion>> call(GetWorkoutSuggestionParams params) =>
      repository.getWorkoutSuggestion(goal: params.goal, recentWorkouts: params.recentWorkouts);
}

class GetWorkoutSuggestionParams {
  final String goal;
  final List<Workout> recentWorkouts;
  const GetWorkoutSuggestionParams({required this.goal, required this.recentWorkouts});
}
