import 'dart:io';
import 'package:albert/features/utils/getx/files/getx_controllers.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:albert/main.dart';

void main() {
  Directory? tempDir;

  setUp(() async {
    Get.reset();
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir!.path);

    try {
      Hive.registerAdapter(ExerciseAdapter());
      Hive.registerAdapter(RoutineAdapter());
      Hive.registerAdapter(WorkoutSessionAdapter());
    } catch (_) {}

    boxExercises = await Hive.openBox<Exercise>('exerciseBox');
    boxRoutines = await Hive.openBox<Routine>('routineBox');
    boxWorkoutSessions = await Hive.openBox<WorkoutSession>('workoutSessionBox');

    registerGetxControllers();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir != null && await tempDir!.exists()) {
      await tempDir!.delete(recursive: true);
    }
  });

  testWidgets('App starts on Home page and can navigate to Workouts', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that our home page is displayed.
    expect(find.text('WELCOME BACK'), findsOneWidget);

    // Tap on the Workouts tab
    expect(find.text('Workouts'), findsOneWidget);
    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle();

    // Verify that we navigated to the Workouts page
    expect(find.text('Pick a routine or build a new one.'), findsOneWidget);
  });
}

