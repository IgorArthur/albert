import 'package:firebase_ai/firebase_ai.dart';
import 'package:get/get.dart';
import '../../data/datasources/coach_remote_datasource.dart';
import '../../data/repositories/coach_repository_impl.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/usecases/ask_coach_question.dart';
import '../../domain/usecases/evaluate_workout.dart';
import '../../domain/usecases/get_workout_suggestion.dart';
import '../controllers/coach_controller.dart';

class CoachBinding extends Bindings {
  @override
  void dependencies() {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
        'You are a certified gym coach. Give concise, safe, evidence-based '
        'workout suggestions and evaluations. Always respond in the exact '
        'format requested by the prompt.',
      ),
    );

    Get.lazyPut<CoachRemoteDataSource>(() => CoachRemoteDataSourceImpl(model));
    Get.lazyPut<CoachRepository>(() => CoachRepositoryImpl(Get.find()));

    Get.lazyPut(() => GetWorkoutSuggestion(Get.find()));
    Get.lazyPut(() => EvaluateWorkout(Get.find()));
    Get.lazyPut(() => AskCoachQuestion(Get.find()));

    Get.lazyPut(() => CoachController(
          getWorkoutSuggestion: Get.find(),
          evaluateWorkoutUsecase: Get.find(),
          askCoachQuestion: Get.find(),
        ));
  }
}
