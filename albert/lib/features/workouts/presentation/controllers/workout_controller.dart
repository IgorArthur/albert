import 'package:get/get.dart';
import '../../domain/entities/workout.dart';
import '../../domain/usecases/add_workout.dart';
import '../../domain/usecases/delete_workout.dart';
import '../../domain/usecases/get_workouts.dart';
import '../../../../core/usecases/usecase.dart';

class WorkoutController extends GetxController {
  static WorkoutController get to => Get.find();

  final GetWorkouts getWorkoutsUsecase;
  final AddWorkout addWorkoutUsecase;
  final DeleteWorkout deleteWorkoutUsecase;

  WorkoutController({
    required this.getWorkoutsUsecase,
    required this.addWorkoutUsecase,
    required this.deleteWorkoutUsecase,
  });

  final workouts = <Workout>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await getWorkoutsUsecase(NoParams());
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (list) => workouts.assignAll(list),
    );
    isLoading.value = false;
  }

  Future<void> addWorkout(Workout workout) async {
    isLoading.value = true;
    final result = await addWorkoutUsecase(AddWorkoutParams(workout: workout));
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (_) => loadWorkouts(),
    );
    isLoading.value = false;
  }

  Future<void> deleteWorkout(String id) async {
    isLoading.value = true;
    final result = await deleteWorkoutUsecase(DeleteWorkoutParams(id: id));
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (_) => loadWorkouts(),
    );
    isLoading.value = false;
  }
}
