import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/workout_local_datasource.dart';
import '../../data/datasources/workout_remote_datasource.dart';
import '../../data/models/workout_model.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/usecases/add_workout.dart';
import '../../domain/usecases/delete_workout.dart';
import '../../domain/usecases/get_workouts.dart';
import '../controllers/workout_controller.dart';

class WorkoutBinding extends Bindings {
  @override
  void dependencies() {
    final Box<WorkoutModel> box = Hive.box<WorkoutModel>('workoutCacheBox');

    Get.lazyPut<WorkoutLocalDataSource>(() => WorkoutLocalDataSourceImpl(box));
    Get.lazyPut<WorkoutRemoteDataSource>(() => WorkoutRemoteDataSourceImpl(FirebaseFirestore.instance));
    Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl(Connectivity()));
    Get.lazyPut<WorkoutRepository>(() => WorkoutRepositoryImpl(
          remote: Get.find(),
          local: Get.find(),
          networkInfo: Get.find(),
        ));

    Get.lazyPut(() => GetWorkouts(Get.find()));
    Get.lazyPut(() => AddWorkout(Get.find()));
    Get.lazyPut(() => DeleteWorkout(Get.find()));

    Get.lazyPut(() => WorkoutController(
          getWorkoutsUsecase: Get.find(),
          addWorkoutUsecase: Get.find(),
          deleteWorkoutUsecase: Get.find(),
        ));
  }
}
