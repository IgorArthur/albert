import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/coach_message.dart';
import '../entities/workout_suggestion.dart';
import '../entities/workout_evaluation.dart';
import '../../../workouts/domain/entities/workout.dart';

abstract class CoachRepository {
  Future<Either<Failure, WorkoutSuggestion>> getWorkoutSuggestion({
    required String goal, // e.g. "build strength", "lose fat"
    required List<Workout> recentWorkouts,
  });

  Future<Either<Failure, WorkoutEvaluation>> evaluateWorkout(Workout workout);

  Future<Either<Failure, CoachMessage>> askQuestion({
    required String question,
    required List<CoachMessage> history,
  });
}
