import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/firebase/files/firebase_utils.dart';
import 'package:albert/features/utils/hive/files/hive_utils.dart';
import 'package:albert/features/utils/l10n/app_translations.dart';
import 'package:albert/features/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  
  await initFirebase();
  await initHiveAndBoxes();
  registerGetxControllers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Subscribe to textSize, language, and theme so the whole tree rebuilds on change.
      ProfileController.to.textSize.value;
      ProfileController.to.language.value;
      ProfileController.to.appTheme.value;

      return GetMaterialApp.router(
        debugShowCheckedModeBanner: false,
        // ── Translations ────────────────────────────────────────────────────
        translations: AppTranslations(),
        locale: ProfileController.to.currentLocale,
        fallbackLocale: const Locale('en', 'US'),
        // ── Theme ───────────────────────────────────────────────────────────
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.white,
          cardColor: const Color(0xFFF2F2F7),
          dividerColor: Colors.black.withValues(alpha: 0.08),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          canvasColor: AppColors.background,
          cardColor: AppColors.surfaceCard,
          dividerColor: AppColors.neutral30,
        ),
        themeMode: ProfileController.to.currentThemeMode,
        // ── Router (GoRouter delegates) ──────────────────────────────────────
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
      );
    });
  }
}
