import 'package:albert/core/error/exceptions.dart';
import 'package:albert/core/error/failures.dart';
import 'package:albert/features/coach/data/datasources/coach_remote_datasource.dart';
import 'package:albert/features/coach/data/repositories/coach_repository_impl.dart';
import 'package:albert/features/coach/domain/entities/coach_message.dart';
import 'package:albert/features/coach/domain/entities/workout_evaluation.dart';
import 'package:albert/features/coach/domain/entities/workout_suggestion.dart';
import 'package:albert/features/workouts/domain/entities/workout.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCoachRemoteDataSource extends Mock implements CoachRemoteDataSource {}

void main() {
  late CoachRepositoryImpl repository;
  late MockCoachRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockCoachRemoteDataSource();
    repository = CoachRepositoryImpl(mockRemote);
  });

  group('getWorkoutSuggestion', () {
    const tGoal = 'gain mass';
    final List<Workout> tRecent = [];
    const tSuggestion = WorkoutSuggestion(
      exerciseName: 'Bench Press',
      sets: 4,
      reps: 8,
      reasoning: 'Good for hypertrophy',
    );

    test('should return WorkoutSuggestion when remote succeeds', () async {
      when(() => mockRemote.getWorkoutSuggestion(goal: tGoal, recentWorkouts: tRecent))
          .thenAnswer((_) async => tSuggestion);

      final result = await repository.getWorkoutSuggestion(goal: tGoal, recentWorkouts: tRecent);

      expect(result, equals(const Right(tSuggestion)));
    });

    test('should return ServerFailure when remote throws ServerException', () async {
      when(() => mockRemote.getWorkoutSuggestion(goal: tGoal, recentWorkouts: tRecent))
          .thenThrow(ServerException());

      final result = await repository.getWorkoutSuggestion(goal: tGoal, recentWorkouts: tRecent);

      expect(result, equals(Left(ServerFailure())));
    });
  });

  group('evaluateWorkout', () {
    final tWorkout = Workout(
      id: '1',
      exerciseName: 'Deadlift',
      sets: 3,
      reps: 5,
      weightKg: 120.0,
      date: DateTime(2026, 7, 18),
    );
    const tEvaluation = WorkoutEvaluation(
      summary: 'Solid lifts',
      improvementTips: ['Watch lower back posture'],
      qualityScore: 85,
    );

    test('should return WorkoutEvaluation when remote succeeds', () async {
      when(() => mockRemote.evaluateWorkout(tWorkout)).thenAnswer((_) async => tEvaluation);

      final result = await repository.evaluateWorkout(tWorkout);

      expect(result, equals(const Right(tEvaluation)));
    });

    test('should return ServerFailure when remote fails', () async {
      when(() => mockRemote.evaluateWorkout(tWorkout)).thenThrow(ServerException());

      final result = await repository.evaluateWorkout(tWorkout);

      expect(result, equals(Left(ServerFailure())));
    });
  });

  group('askQuestion', () {
    const tQuestion = 'How to warm up?';
    final List<CoachMessage> tHistory = [];

    test('should return CoachMessage when remote responds successfully', () async {
      when(() => mockRemote.askQuestion(question: tQuestion, history: tHistory))
          .thenAnswer((_) async => 'Do light cardio');

      final result = await repository.askQuestion(question: tQuestion, history: tHistory);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should be right'),
        (msg) {
          expect(msg.text, 'Do light cardio');
          expect(msg.sender, MessageSender.coach);
        },
      );
    });

    test('should return ServerFailure when remote fails', () async {
      when(() => mockRemote.askQuestion(question: tQuestion, history: tHistory))
          .thenThrow(ServerException());

      final result = await repository.askQuestion(question: tQuestion, history: tHistory);

      expect(result, equals(Left(ServerFailure())));
    });
  });
}
