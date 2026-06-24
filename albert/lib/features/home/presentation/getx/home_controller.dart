import 'package:albert/features/utils/go_router/files/routes.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  // ─── State ────────────────────────────────────────────────────────────────

  final int level = 1;
  final int currentXp = 0;
  final int maxXp = 250;
  final int streakDays = 0;
  final int sessionsLogged = 0;

  // ─── Getters ──────────────────────────────────────────────────────────────

  String get nextWorkoutName =>
      WorkoutsController.to.routines.isNotEmpty
          ? WorkoutsController.to.routines.first.name
          : 'No routine';

  RxList<Routine> get routines => WorkoutsController.to.routines;

  // ─── Actions ──────────────────────────────────────────────────────────────

  void startNextWorkout() {
    // TODO: navigate to workout session
  }

  void openCoach() {
    // TODO: navigate to Coach Albert chat
  }

  void onRoutineTap(Routine routine) {
    // TODO: navigate to routine detail
  }

  void seeAllRoutines(BuildContext context) {
    context.go(Routes.workoutsPage);
  }
}
