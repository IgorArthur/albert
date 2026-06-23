import 'package:albert/features/utils/getx/files/getx_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:albert/main.dart';

void main() {
  setUp(() {
    Get.reset();
    registerGetxControllers();
  });

  testWidgets('App starts on Home page and can navigate to Workouts', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that our home page is displayed.
    expect(find.text('Home Page'), findsOneWidget);

    // Tap on the Workouts tab
    expect(find.text('Workouts'), findsOneWidget);
    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle();

    // Verify that we navigated to the Workouts page
    expect(find.text('Pick a routine or build a new one.'), findsOneWidget);
  });
}
