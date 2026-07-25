import 'package:albert/features/utils/utils.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/profile/domain/models/user_profile.dart';
import 'package:albert/features/profile/domain/repositories/profile_repository.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:albert/features/workouts/presentation/controllers/workout_controller.dart';
import 'package:albert/features/workouts/domain/usecases/get_workouts.dart';
import 'package:albert/core/usecases/usecase.dart';
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
    bool success = false;

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
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final profileRepo = Get.find<ProfileRepository>();
        final existing = await profileRepo.getProfile();

        final profile = UserProfile(
          uid: user.uid,
          email: user.email ?? existing?.email ?? '',
          displayName: user.displayName ?? existing?.displayName ?? 'Athlete',
          photoUrl: user.photoURL ?? existing?.photoUrl ?? '',
          avatar: existing?.avatar ?? '💪',
          heightCm: existing?.heightCm ?? 180.0,
          weightKg: existing?.weightKg ?? 75.0,
          dateOfBirth: existing?.dateOfBirth ?? DateTime(1998, 10, 24),
        );
        await profileRepo.saveProfile(profile);

        if (Get.isRegistered<ProfileController>()) {
          ProfileController.to.loadUserFromStorage();
        }

        // Hydrate stored Routines from Firestore
        if (Get.isRegistered<WorkoutsController>()) {
          await boxRoutines.clear();
          WorkoutsController.to.refreshRoutines();
        }

        // Hydrate stored Workouts from Firestore
        if (Get.isRegistered<GetWorkouts>()) {
          try {
            final workoutsResult =
                await Get.find<GetWorkouts>().call(NoParams());
            workoutsResult.fold(
              (failure) => debugPrint(
                  'Error hydrating workouts from Firestore: ${failure.message}'),
              (list) => debugPrint(
                  'Successfully hydrated ${list.length} workouts from Firestore'),
            );
          } catch (e) {
            debugPrint('Error during workout hydration: $e');
          }
        }

        if (Get.isRegistered<WorkoutController>()) {
          Get.find<WorkoutController>().loadWorkouts();
        }
      }
      debugPrint('User logged in with Google: ${user?.displayName}');
      success = true;
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

    if (success) {
      router.go(Routes.homePage);
    }
  }

  void continueWithoutLogin() {
    debugPrint('Continue without login pressed');
    router.go(Routes.homePage);
  }
}
