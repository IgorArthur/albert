import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
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
  String get heightLabel =>
      isMetric.value ? 'profile_height_cm'.tr : 'profile_height_in'.tr;
  String get weightLabel =>
      isMetric.value ? 'profile_weight_kg'.tr : 'profile_weight_lb'.tr;
  String get weightUnitDisplay => isMetric.value ? 'KG' : 'LB';

  // ─── Notifications ────────────────────────────────────────────────────────

  final RxBool workoutReminders = true.obs;
  final RxBool streakAlerts = true.obs;
  final RxBool albertTips = false.obs;

  // ─── Font Size ────────────────────────────────────────────────────────────

  final Rx<TextSize> textSize = TextSize.normal.obs;

  void setTextSize(TextSize size) {
    textSize.value = size;
    TextSizeManager.setSize(size);
  }

  // ─── Language ─────────────────────────────────────────────────────────────

  final RxString language = 'en'.obs;

  Locale get currentLocale =>
      language.value == 'pt' ? const Locale('pt', 'BR') : const Locale('en', 'US');

  void setLanguage(String lang) {
    language.value = lang;
    Get.updateLocale(currentLocale);
  }

  // ─── Gamification (read-only) ─────────────────────────────────────────────

  final int level = 1;
  final int currentXp = 0;
  final int maxXp = 250;
  final int streakDays = 0;

  String get emailSubtitle =>
      email.value.isEmpty ? 'profile_no_email'.tr : email.value;

  String get xpLabel =>
      'profile_xp_label'.trParams({'xp': '$currentXp', 'max': '$maxXp'});
  String get streakLabel =>
      'profile_streak_label'.trParams({'days': '$streakDays'});
  String get levelLabel =>
      'profile_level_label'.trParams({'level': '$level'});

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
        ? 'profile_name_hint'.tr
        : nameController.text.trim();
    Get.snackbar(
      'profile_saved_title'.tr,
      'profile_saved_body'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveEmail() {
    email.value = emailController.text.trim();
    Get.snackbar(
      'profile_email_saved_title'.tr,
      'profile_email_saved_body'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveBodyStats() {
    heightCm.value = double.tryParse(heightController.text) ?? heightCm.value;
    weightKg.value = double.tryParse(weightController.text) ?? weightKg.value;
    Get.snackbar(
      'profile_body_saved_title'.tr,
      'profile_body_saved_body'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'profile_reset_title'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'profile_reset_body'.tr,
          style: const TextStyle(color: AppColors.neutral60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('profile_reset_cancel'.tr,
                style: const TextStyle(color: AppColors.neutral60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              resetSettings();
            },
            child: Text('profile_reset_confirm'.tr,
                style: const TextStyle(
                    color: AppColors.error100, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void resetSettings() {
    selectedAvatar.value = '💪';
    displayName.value = 'profile_name_hint'.tr;
    email.value = '';
    nameController.text = displayName.value;
    emailController.text = '';
    heightCm.value = 180;
    weightKg.value = 75;
    heightController.text = '180';
    weightController.text = '75';
    isMetric.value = true;
    workoutReminders.value = true;
    streakAlerts.value = true;
    albertTips.value = false;
    setTextSize(TextSize.normal);
    setLanguage('en');
    Get.snackbar(
      'profile_reset_done_title'.tr,
      'profile_reset_done_body'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
