import 'package:albert/core/usecases/usecase.dart';
import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/workouts/domain/usecases/get_workouts.dart';
import 'package:albert/features/workouts/presentation/controllers/workout_controller.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Global pull-to-refresh handler to refresh all app data from local/remote sources.
Future<void> refreshAppData() async {
  debugPrint('Refreshing app data via pull-down...');

  // 1. Refresh User Profile
  if (Get.isRegistered<ProfileController>()) {
    ProfileController.to.loadUserFromStorage();
  }

  // 2. Refresh Routines
  if (Get.isRegistered<WorkoutsController>()) {
    WorkoutsController.to.refreshRoutines();
  }

  // 3. Refresh Workouts Log
  if (Get.isRegistered<GetWorkouts>()) {
    try {
      await Get.find<GetWorkouts>().call(NoParams());
    } catch (e) {
      debugPrint('Error calling GetWorkouts during refresh: $e');
    }
  }

  if (Get.isRegistered<WorkoutController>()) {
    await Get.find<WorkoutController>().loadWorkouts();
  }
}
