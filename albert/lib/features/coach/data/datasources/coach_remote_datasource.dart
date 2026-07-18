import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../../domain/entities/workout_suggestion.dart';
import '../../domain/entities/workout_evaluation.dart';
import '../../domain/entities/coach_message.dart';

abstract class CoachRemoteDataSource {
  Future<WorkoutSuggestion> getWorkoutSuggestion({
    required String goal,
    required List<Workout> recentWorkouts,
  });
  Future<WorkoutEvaluation> evaluateWorkout(Workout workout);
  Future<String> askQuestion({
    required String question,
    required List<CoachMessage> history,
  });
}

class CoachRemoteDataSourceImpl implements CoachRemoteDataSource {
  final GenerativeModel model;

  CoachRemoteDataSourceImpl(this.model);

  @override
  Future<WorkoutSuggestion> getWorkoutSuggestion({
    required String goal,
    required List<Workout> recentWorkouts,
  }) async {
    try {
      final history = recentWorkouts
          .map((w) => '${w.exerciseName}: ${w.sets}x${w.reps} at ${w.weightKg}kg on ${w.date}')
          .join('\n');

      final prompt = '''
Goal: $goal
Recent workout history:
$history

Suggest the next workout. Respond ONLY as JSON with keys:
exerciseName (string), sets (int), reps (int), reasoning (string).
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final cleanedText = _stripCodeFences(text);
      final json = jsonDecode(cleanedText);

      return WorkoutSuggestion(
        exerciseName: json['exerciseName'] as String? ?? 'Custom Exercise',
        sets: json['sets'] as int? ?? 3,
        reps: json['reps'] as int? ?? 10,
        reasoning: json['reasoning'] as String? ?? '',
      );
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<WorkoutEvaluation> evaluateWorkout(Workout workout) async {
    try {
      final prompt = '''
Evaluate this workout: ${workout.exerciseName}, ${workout.sets} sets of ${workout.reps} reps at ${workout.weightKg}kg.

Respond ONLY as JSON with keys:
summary (string), improvementTips (array of strings), qualityScore (int 0-100).
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final cleanedText = _stripCodeFences(text);
      final json = jsonDecode(cleanedText);

      return WorkoutEvaluation(
        summary: json['summary'] as String? ?? '',
        improvementTips: List<String>.from(json['improvementTips'] as List? ?? []),
        qualityScore: json['qualityScore'] as int? ?? 50,
      );
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<String> askQuestion({
    required String question,
    required List<CoachMessage> history,
  }) async {
    try {
      final chatHistory = history
          .map((m) => Content(m.sender == MessageSender.user ? 'user' : 'model', [TextPart(m.text)]))
          .toList();

      final chat = model.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(question));
      return response.text ?? '';
    } catch (_) {
      throw ServerException();
    }
  }

  String _stripCodeFences(String text) =>
      text.replaceAll('```json', '').replaceAll('```', '').trim();
}
