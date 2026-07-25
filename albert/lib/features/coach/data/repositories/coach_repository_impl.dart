import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../../domain/entities/coach_message.dart';
import '../../domain/entities/workout_evaluation.dart';
import '../../domain/entities/workout_suggestion.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/coach_remote_datasource.dart';

class CoachRepositoryImpl implements CoachRepository {
  final CoachRemoteDataSource remote;
  CoachRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, WorkoutSuggestion>> getWorkoutSuggestion({
    required String goal,
    required List<Workout> recentWorkouts,
  }) async {
    try {
      final result = await remote.getWorkoutSuggestion(
        goal: goal,
        recentWorkouts: recentWorkouts,
      );
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, WorkoutEvaluation>> evaluateWorkout(Workout workout) async {
    try {
      return Right(await remote.evaluateWorkout(workout));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CoachMessage>> askQuestion({
    required String question,
    required List<CoachMessage> history,
  }) async {
    try {
      final answerText = await remote.askQuestion(question: question, history: history);
      return Right(CoachMessage(
        text: answerText,
        sender: MessageSender.coach,
        timestamp: DateTime.now(),
      ));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
