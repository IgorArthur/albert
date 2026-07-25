import 'package:albert/features/home/presentation/getx/home_controller.dart';
import 'package:albert/features/navigation_bar/presentation/widgets/getx/navigation_bar_controller.dart';
import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/progress/presentation/getx/progress_controller.dart';
import 'package:albert/features/workouts/workouts.dart';
import 'package:albert/features/workouts/presentation/getx/session_controller.dart';
import 'package:albert/features/profile/profile.dart';
import 'package:albert/features/home/home.dart';
import 'package:albert/features/login/login.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/profile/domain/repositories/profile_repository.dart';
import 'package:albert/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:albert/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:albert/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:albert/core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:albert/features/workouts/data/datasources/workout_local_datasource.dart';
import 'package:albert/features/workouts/data/datasources/workout_remote_datasource.dart';
import 'package:albert/features/workouts/data/models/workout_model.dart';
import 'package:albert/features/workouts/data/repositories/workout_repository_impl.dart';
import 'package:albert/features/workouts/domain/repositories/workout_repository.dart';
import 'package:albert/features/workouts/domain/usecases/add_workout.dart';
import 'package:albert/features/workouts/domain/usecases/delete_workout.dart';
import 'package:albert/features/workouts/domain/usecases/get_workouts.dart';
import 'package:get/get.dart';

void registerGetxControllers() {
  // Register Data sources & Repositories
  final profileLocalSource = ProfileLocalDataSourceImpl(boxAuth);
  final profileRemoteSource = ProfileRemoteDataSourceImpl();
  Get.put<ProfileRepository>(
    ProfileRepositoryImpl(
      localDataSource: profileLocalSource,
      remoteDataSource: profileRemoteSource,
    ),
    permanent: true,
  );

  // Register Workouts Clean Architecture dependencies & usecases
  final workoutCacheBox = Hive.box<WorkoutModel>('workoutCacheBox');
  final workoutLocalSource = WorkoutLocalDataSourceImpl(workoutCacheBox);
  final workoutRemoteSource = WorkoutRemoteDataSourceImpl();
  final networkInfo = NetworkInfoImpl(Connectivity());
  final workoutRepo = WorkoutRepositoryImpl(
    remote: workoutRemoteSource,
    local: workoutLocalSource,
    networkInfo: networkInfo,
  );
  Get.put<WorkoutRepository>(workoutRepo, permanent: true);

  Get.put(GetWorkouts(workoutRepo), permanent: true);
  Get.put(AddWorkout(workoutRepo), permanent: true);
  Get.put(DeleteWorkout(workoutRepo), permanent: true);

  Get.put(NavigationBarController());
  Get.put(WorkoutsController());
  Get.put(SessionController());
  Get.put(LoginController());
  Get.put(ProfileController(), permanent: true);
  Get.put(ProgressController(), permanent: true);
  Get.put(HomeController(), permanent: true);
}
