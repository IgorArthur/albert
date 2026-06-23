import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/hive/files/hive_utils.dart';
import 'package:albert/features/utils/utils.dart';
import 'package:flutter/material.dart';

void main() async {
  await initHiveAndBoxes();
  registerGetxControllers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
      ),
      routerConfig: router,
    );
  }
}
