import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/utils/go_router/files/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  // ─── Avatar & Profile ─────────────────────────────────────────────────────

  final List<String> avatarOptions = ['💪', '🔥', '🏋️', '🥇', '⚡', '🧠', '🦾', '🐺', '👽'];

  final RxString selectedAvatar = '💪'.obs;
  final RxString displayName = 'Athlete'.obs;
  final RxString email = ''.obs;
  final RxString photoUrl = ''.obs;
  final RxBool isEditingProfile = false.obs;

  late final TextEditingController nameController;
  late final TextEditingController emailController;

  // ─── Body Stats ───────────────────────────────────────────────────────────

  final RxDouble heightCm = 180.0.obs;
  final RxDouble weightKg = 75.0.obs;
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();

  late final TextEditingController heightController;
  late final TextEditingController weightController;
  late final TextEditingController birthdayController;

  // ─── Units ────────────────────────────────────────────────────────────────

  final RxBool isMetric = true.obs;

  String get heightUnit => isMetric.value ? 'cm' : 'in';
  String get weightUnit => isMetric.value ? 'kg' : 'lb';
  String get heightLabel =>
      isMetric.value ? 'profile_height_cm'.tr : 'profile_height_in'.tr;
  String get weightLabel =>
      isMetric.value ? 'profile_weight_kg'.tr : 'profile_weight_lb'.tr;
  String get weightUnitDisplay => isMetric.value ? 'KG' : 'LB';

  String get formattedBirthday {
    if (dateOfBirth.value == null) return '';
    final d = dateOfBirth.value!.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  int? get age {
    if (dateOfBirth.value == null) return null;
    final today = DateTime.now();
    final d = dateOfBirth.value!.toLocal();
    int age = today.year - d.year;
    if (today.month < d.month ||
        (today.month == d.month && today.day < d.day)) {
      age--;
    }
    return age;
  }

  final RxString appTheme = 'Dark'.obs;

  ThemeMode get currentThemeMode {
    switch (appTheme.value) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'System':
      default:
        return ThemeMode.system;
    }
  }

  void setAppTheme(String theme) {
    appTheme.value = theme;
    boxAuth.put('appTheme', theme);
    Get.changeThemeMode(currentThemeMode);
  }

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
    birthdayController = TextEditingController();
    loadUserFromStorage();
  }

  void loadUserFromStorage() {
    final user = boxAuth.get('user');
    final isLoggedIn = user != null && user is Map;
    if (isLoggedIn) {
      displayName.value = user['displayName'] ?? 'Athlete';
      email.value = user['email'] ?? '';
      photoUrl.value = user['photoURL'] ?? '';
      nameController.text = displayName.value;
      emailController.text = email.value;
    }

    heightCm.value = boxAuth.get('height') ?? 180.0;
    weightKg.value = boxAuth.get('weight') ?? 75.0;
    heightController.text = heightCm.value.toInt().toString();
    weightController.text = weightKg.value.toInt().toString();

    String? savedBirthday;
    if (isLoggedIn) {
      if (user['birthday'] != null) {
        savedBirthday = user['birthday'];
      } else {
        savedBirthday = DateTime(1998, 10, 24).toIso8601String();
        final updatedUser = Map<String, dynamic>.from(user);
        updatedUser['birthday'] = savedBirthday;
        boxAuth.put('user', updatedUser);
      }
    } else {
      savedBirthday = boxAuth.get('birthday');
    }

    if (savedBirthday != null) {
      dateOfBirth.value = DateTime.tryParse(savedBirthday);
      birthdayController.text = formattedBirthday;
    } else {
      dateOfBirth.value = null;
      birthdayController.text = '';
    }

    appTheme.value = boxAuth.get('appTheme') ?? 'Dark';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    heightController.dispose();
    weightController.dispose();
    birthdayController.dispose();
    super.onClose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void selectAvatar(String avatar) {
    selectedAvatar.value = avatar;
    photoUrl.value = '';
    final user = boxAuth.get('user');
    if (user != null && user is Map) {
      final updatedUser = Map<String, dynamic>.from(user);
      updatedUser['photoURL'] = '';
      boxAuth.put('user', updatedUser);
    }
  }

  void toggleUnit(bool metric) => isMetric.value = metric;

  void saveProfile() async {
    displayName.value = nameController.text.trim().isEmpty
        ? 'profile_name_hint'.tr
        : nameController.text.trim();
    
    // Save to Hive auth box as well so it persists
    final user = boxAuth.get('user');
    if (user != null && user is Map) {
      final updatedUser = Map<String, dynamic>.from(user);
      updatedUser['displayName'] = displayName.value;
      await boxAuth.put('user', updatedUser);
    } else {
      // In guest mode, save guest details
      await boxAuth.put('user', {
        'displayName': displayName.value,
        'email': '',
      });
    }

    isEditingProfile.value = false;
    
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

  void saveBodyInfo() async {
    heightCm.value = double.tryParse(heightController.text) ?? heightCm.value;
    weightKg.value = double.tryParse(weightController.text) ?? weightKg.value;
    
    await boxAuth.put('height', heightCm.value);
    await boxAuth.put('weight', weightKg.value);

    final user = boxAuth.get('user');
    final isLoggedIn = user != null && user is Map;

    if (dateOfBirth.value != null) {
      if (isLoggedIn) {
        final updatedUser = Map<String, dynamic>.from(user);
        updatedUser['birthday'] = dateOfBirth.value!.toIso8601String();
        await boxAuth.put('user', updatedUser);
      } else {
        await boxAuth.put('birthday', dateOfBirth.value!.toIso8601String());
      }
    } else {
      if (isLoggedIn) {
        final updatedUser = Map<String, dynamic>.from(user);
        updatedUser.remove('birthday');
        await boxAuth.put('user', updatedUser);
      } else {
        await boxAuth.delete('birthday');
      }
    }
    
    Get.snackbar(
      'profile_body_saved_title'.tr,
      'profile_body_saved_body'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth.value ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary100,
              onPrimary: Colors.white,
              surface: AppColors.surfaceCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateOfBirth.value = picked;
      birthdayController.text = formattedBirthday;
    }
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
    isMetric.value = true;
    workoutReminders.value = true;
    streakAlerts.value = true;
    albertTips.value = false;
    appTheme.value = 'Dark';
    setTextSize(TextSize.normal);
    setLanguage('en');

    // Save resets to Hive
    boxAuth.put('appTheme', 'Dark');
    boxAuth.delete('height');
    boxAuth.delete('weight');
    heightCm.value = 180;
    weightKg.value = 75;
    heightController.text = '180';
    weightController.text = '75';

    final user = boxAuth.get('user');
    final isLoggedIn = user != null && user is Map;
    if (!isLoggedIn) {
      // In Guest mode, we can also reset local birthday
      boxAuth.delete('birthday');
      dateOfBirth.value = null;
      birthdayController.text = '';
    }

    Get.snackbar(
      'profile_reset_done_title'.tr,
      'profile_reset_done_body'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void signOut() async {
    try {
      await boxAuth.delete('user');
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      displayName.value = 'Athlete';
      email.value = '';
      photoUrl.value = '';
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
    // Navigate back to the Login page.
    router.go(Routes.loginPage);
  }
}
