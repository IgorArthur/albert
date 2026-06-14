import 'package:albert/features/utils/utils.dart';
import 'package:flutter/material.dart';

void main() {
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
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: router,
    );
  }
}
