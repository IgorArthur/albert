import 'package:albert/features/utils/go_router/files/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  // ─── Actions ──────────────────────────────────────────────────────────────

  void continueWithGoogle(BuildContext context) {
    debugPrint('Google Sign-In pressed');
    // For now, bypass login and navigate to Home page
    context.go(Routes.homePage);
  }

  void continueWithoutLogin(BuildContext context) {
    debugPrint('Continue without login pressed');
    context.go(Routes.homePage);
  }
}
