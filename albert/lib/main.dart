import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/hive/files/hive_utils.dart';
import 'package:albert/features/utils/l10n/app_translations.dart';
import 'package:albert/features/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  await initHiveAndBoxes();
  registerGetxControllers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Subscribe to textSize and language so the whole tree rebuilds on change.
      ProfileController.to.textSize.value;
      ProfileController.to.language.value;

      return GetMaterialApp.router(
        debugShowCheckedModeBanner: false,
        // ── Translations ────────────────────────────────────────────────────
        translations: AppTranslations(),
        locale: ProfileController.to.currentLocale,
        fallbackLocale: const Locale('en', 'US'),
        // ── Theme ───────────────────────────────────────────────────────────
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
        ),
        // ── Router (GoRouter delegates) ──────────────────────────────────────
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
      );
    });
  }
}
