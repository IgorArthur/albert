import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  // State matching the screenshot
  final int level = 1;
  final int currentXp = 0;
  final int maxXp = 250;
  final int streakDays = 0;
  final int sessionsLogged = 0;

  final String nextWorkoutName = "Push Day";

  final List<RoutineModel> routines = const [
    RoutineModel(name: "Push Day", exercisesCount: 4, icon: "🔥"),
    RoutineModel(name: "Pull Day", exercisesCount: 4, icon: "⚡"),
    RoutineModel(name: "Leg Day", exercisesCount: 4, icon: "🍗"),
  ];
}

class RoutineModel {
  final String name;
  final int exercisesCount;
  final String icon;

  const RoutineModel({
    required this.name,
    required this.exercisesCount,
    required this.icon,
  });
}
