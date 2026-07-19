import 'package:albert/features/utils/utils.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/profile/domain/models/user_profile.dart';
import 'package:albert/features/profile/domain/repositories/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  // ─── Actions ──────────────────────────────────────────────────────────────

  void continueWithGoogle(BuildContext context) async {
    debugPrint('Google Sign-In pressed');
    showLoadingOverlay(context, 'login_loading'.tr);
    try {
      // 1. Trigger the native Google Sign-In flow.
      final googleUser = await GoogleSignIn.instance.authenticate();

      // 2. Obtain the auth details (synchronous in v7.0.0+).
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Create a new credential using only the ID token.
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the Google credentials.
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final profile = UserProfile(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Athlete',
          photoUrl: user.photoURL ?? '',
          avatar: '💪',
          heightCm: 180.0,
          weightKg: 75.0,
          dateOfBirth: DateTime(1998, 10, 24),
        );
        await Get.find<ProfileRepository>().saveProfile(profile);

        if (Get.isRegistered<ProfileController>()) {
          ProfileController.to.loadUserFromStorage();
        }
      }
      debugPrint('User logged in with Google: ${user?.displayName}');

      // 5. Navigate to the Home page using the global router.
      router.go(Routes.homePage);
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      Get.snackbar(
        'Error',
        'Failed to sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void continueWithoutLogin() {
    debugPrint('Continue without login pressed');
    router.go(Routes.homePage);
  }
}
