import 'package:albert/features/utils/go_router/files/routes.dart';
import 'package:albert/features/progress/presentation/getx/progress_controller.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/presentation/getx/session_controller.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  // ─── State ────────────────────────────────────────────────────────────────

  // ─── Getters ──────────────────────────────────────────────────────────────

  int get level => ProgressController.to.level.value;
  int get currentXp => ProgressController.to.currentXp.value;
  int get maxXp => ProgressController.to.xpToNextLevel.value + currentXp;
  int get streakDays => ProgressController.to.streakDays.value;
  int get sessionsLogged => ProgressController.to.totalSessions.value;

  String get nextWorkoutName =>
      WorkoutsController.to.routines.isNotEmpty
          ? WorkoutsController.to.routines.first.name
          : 'No routine';

  RxList<Routine> get routines => WorkoutsController.to.routines;

  // ─── Actions ──────────────────────────────────────────────────────────────

  void startNextWorkout(BuildContext context) {
    final routines = WorkoutsController.to.routines;
    if (routines.isEmpty) return;
    SessionController.to.showStartConfirmation(context, routines.first);
  }

  void openCoach() {
    rootNavigatorKey.currentContext?.push(Routes.coachPage);
  }

  void onRoutineTap(BuildContext context, Routine routine) {
    // Navigate to the Workouts tab first.
    // The WorkoutsController will pick up the pending routine and open the sheet
    // once the branch is successfully mounted, avoiding GoRouter race conditions.
    WorkoutsController.to.setPendingEditRoutine(routine);
    context.go(Routes.workoutsPage);
  }

  void seeAllRoutines(BuildContext context) {
    context.go(Routes.workoutsPage);
  }
}

