import 'package:get/get.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../../domain/entities/coach_message.dart';
import '../../domain/usecases/ask_coach_question.dart';
import '../../domain/usecases/evaluate_workout.dart';
import '../../domain/usecases/get_workout_suggestion.dart';

class CoachController extends GetxController {
  final GetWorkoutSuggestion getWorkoutSuggestion;
  final EvaluateWorkout evaluateWorkoutUsecase;
  final AskCoachQuestion askCoachQuestion;

  CoachController({
    required this.getWorkoutSuggestion,
    required this.evaluateWorkoutUsecase,
    required this.askCoachQuestion,
  });

  final messages = <CoachMessage>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> sendQuestion(String question) async {
    if (question.trim().isEmpty) return;

    isLoading.value = true;
    errorMessage.value = null;

    final userMsg = CoachMessage(
      text: question,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    messages.add(userMsg);

    final result = await askCoachQuestion(AskCoachQuestionParams(question: question, history: messages));
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (answer) => messages.add(answer),
    );

    isLoading.value = false;
  }

  Future<void> suggestNextWorkout({
    required String goal,
    required List<Workout> recentWorkouts,
  }) async {
    isLoading.value = true;
    final result = await getWorkoutSuggestion(GetWorkoutSuggestionParams(goal: goal, recentWorkouts: recentWorkouts));
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (suggestion) => messages.add(CoachMessage(
        text: '🔥 Suggested Suggestion:\n${suggestion.exerciseName}: ${suggestion.sets}x${suggestion.reps}\n\nReasoning: ${suggestion.reasoning}',
        sender: MessageSender.coach,
        timestamp: DateTime.now(),
      )),
    );
    isLoading.value = false;
  }
}
