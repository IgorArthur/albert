import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  // ─── Avatar & Profile ─────────────────────────────────────────────────────

  final List<String> avatarOptions = ['💪', '🔥', '🏆', '🥇', '⚡', '🧠', '💥', '🐺'];

  final RxString selectedAvatar = '💪'.obs;
  final RxString displayName = 'Athlete'.obs;
  final RxString email = ''.obs;

  late final TextEditingController nameController;
  late final TextEditingController emailController;

  // ─── Body Stats ───────────────────────────────────────────────────────────

  final RxDouble heightCm = 180.0.obs;
  final RxDouble weightKg = 75.0.obs;

  late final TextEditingController heightController;
  late final TextEditingController weightController;

  // ─── Units ────────────────────────────────────────────────────────────────

  final RxBool isMetric = true.obs;

  String get heightUnit => isMetric.value ? 'cm' : 'in';
  String get weightUnit => isMetric.value ? 'kg' : 'lb';

  // ─── Notifications ────────────────────────────────────────────────────────

  final RxBool workoutReminders = true.obs;
  final RxBool streakAlerts = true.obs;
  final RxBool albertTips = false.obs;

  // ─── Gamification (read-only, from HomeController) ───────────────────────

  final int level = 1;
  final int currentXp = 0;
  final int maxXp = 250;
  final int streakDays = 0;

  String get emailSubtitle =>
      email.value.isEmpty ? 'No email set' : email.value;

  String get xpLabel => '$currentXp/$maxXp XP';
  String get streakLabel => '${streakDays}d streak';
  String get levelLabel => 'Lvl $level';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: displayName.value);
    emailController = TextEditingController(text: email.value);
    heightController = TextEditingController(text: heightCm.value.toInt().toString());
    weightController = TextEditingController(text: weightKg.value.toInt().toString());
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.onClose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void selectAvatar(String avatar) => selectedAvatar.value = avatar;

  void toggleUnit(bool metric) => isMetric.value = metric;

  void saveProfile() {
    displayName.value = nameController.text.trim().isEmpty
        ? 'Athlete'
        : nameController.text.trim();
    Get.snackbar(
      'Profile saved',
      'Your profile has been updated.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveEmail() {
    email.value = emailController.text.trim();
    Get.snackbar(
      'Account saved',
      'Your email has been updated.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveBodyStats() {
    heightCm.value = double.tryParse(heightController.text) ?? heightCm.value;
    weightKg.value = double.tryParse(weightController.text) ?? weightKg.value;
    Get.snackbar(
      'Body stats saved',
      'Your stats have been updated.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will restore all settings to their defaults. Are you sure?',
          style: TextStyle(color: AppColors.neutral60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.neutral60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              resetSettings();
            },
            child: const Text('Reset',
                style: TextStyle(
                    color: AppColors.error100, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void resetSettings() {
    selectedAvatar.value = '💪';
    displayName.value = 'Athlete';
    email.value = '';
    nameController.text = 'Athlete';
    emailController.text = '';
    heightCm.value = 180;
    weightKg.value = 75;
    heightController.text = '180';
    weightController.text = '75';
    isMetric.value = true;
    workoutReminders.value = true;
    streakAlerts.value = true;
    albertTips.value = false;
    Get.snackbar(
      'Settings reset',
      'All settings have been restored to defaults.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
