import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/utils/utils.dart';
import 'package:albert/features/profile/domain/models/user_profile.dart';
import 'package:albert/features/profile/domain/repositories/profile_repository.dart';
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

  void loadUserFromStorage() async {
    final profile = await Get.find<ProfileRepository>().getProfile();
    if (profile != null) {
      displayName.value = profile.displayName;
      email.value = profile.email;
      photoUrl.value = profile.photoUrl;
      selectedAvatar.value = profile.avatar;
      nameController.text = profile.displayName;
      emailController.text = profile.email;
      heightCm.value = profile.heightCm;
      weightKg.value = profile.weightKg;
      heightController.text = profile.heightCm.toInt().toString();
      weightController.text = profile.weightKg.toInt().toString();
      dateOfBirth.value = profile.dateOfBirth;
      birthdayController.text = formattedBirthday;
    } else {
      // In Guest Mode default state
      displayName.value = 'Athlete';
      email.value = '';
      photoUrl.value = '';
      selectedAvatar.value = '💪';
      nameController.text = 'Athlete';
      emailController.text = '';
      heightCm.value = 180.0;
      weightKg.value = 75.0;
      heightController.text = '180';
      weightController.text = '75';
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

  void selectAvatar(String avatar) async {
    selectedAvatar.value = avatar;
    photoUrl.value = '';
    
    // Save state back through repository
    final current = UserProfile(
      uid: email.value.isNotEmpty ? (boxAuth.get('user')?['uid'] ?? '') : '',
      email: email.value,
      displayName: displayName.value,
      photoUrl: '',
      avatar: avatar,
      heightCm: heightCm.value,
      weightKg: weightKg.value,
      dateOfBirth: dateOfBirth.value,
    );
    await Get.find<ProfileRepository>().saveProfile(current);
  }

  void toggleUnit(bool metric) => isMetric.value = metric;

  void saveProfile() async {
    displayName.value = nameController.text.trim().isEmpty
        ? 'profile_name_hint'.tr
        : nameController.text.trim();
    
    final current = UserProfile(
      uid: email.value.isNotEmpty ? (boxAuth.get('user')?['uid'] ?? '') : '',
      email: email.value,
      displayName: displayName.value,
      photoUrl: photoUrl.value,
      avatar: selectedAvatar.value,
      heightCm: heightCm.value,
      weightKg: weightKg.value,
      dateOfBirth: dateOfBirth.value,
    );
    await Get.find<ProfileRepository>().saveProfile(current);

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
    
    final current = UserProfile(
      uid: email.value.isNotEmpty ? (boxAuth.get('user')?['uid'] ?? '') : '',
      email: email.value,
      displayName: displayName.value,
      photoUrl: photoUrl.value,
      avatar: selectedAvatar.value,
      heightCm: heightCm.value,
      weightKg: weightKg.value,
      dateOfBirth: dateOfBirth.value,
    );
    await Get.find<ProfileRepository>().saveProfile(current);
    
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

  void resetSettings() async {
    isMetric.value = true;
    workoutReminders.value = true;
    streakAlerts.value = true;
    albertTips.value = false;
    appTheme.value = 'Dark';
    setTextSize(TextSize.normal);
    setLanguage('en');

    // Save resets to Hive
    await boxAuth.put('appTheme', 'Dark');

    final user = boxAuth.get('user');
    final isLoggedIn = user != null && user is Map;
    if (!isLoggedIn) {
      // In Guest mode, reset everything
      await Get.find<ProfileRepository>().clearProfile();
      displayName.value = 'Athlete';
      email.value = '';
      photoUrl.value = '';
      selectedAvatar.value = '💪';
      nameController.text = 'Athlete';
      emailController.text = '';
      heightCm.value = 180.0;
      weightKg.value = 75.0;
      heightController.text = '180';
      weightController.text = '75';
      dateOfBirth.value = null;
      birthdayController.text = '';
    } else {
      // In Google logged-in mode, reset only local height and weight
      heightCm.value = 180.0;
      weightKg.value = 75.0;
      heightController.text = '180';
      weightController.text = '75';
      
      final current = UserProfile(
        uid: user['uid'] ?? '',
        email: user['email'] ?? '',
        displayName: user['displayName'] ?? 'Athlete',
        photoUrl: user['photoURL'] ?? '',
        avatar: selectedAvatar.value,
        heightCm: 180.0,
        weightKg: 75.0,
        dateOfBirth: dateOfBirth.value,
      );
      await Get.find<ProfileRepository>().saveProfile(current);
    }

    Get.snackbar(
      'profile_reset_done_title'.tr,
      'profile_reset_done_body'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'profile_sign_out_title'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'profile_sign_out_body'.tr,
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
              signOut(context);
            },
            child: Text('profile_sign_out_confirm'.tr,
                style: const TextStyle(
                    color: AppColors.error100, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void signOut(BuildContext context) async {
    showLoadingOverlay(context, 'logout_loading'.tr);
    try {
      await Get.find<ProfileRepository>().clearProfile();
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      displayName.value = 'Athlete';
      email.value = '';
      photoUrl.value = '';
      selectedAvatar.value = '💪';
      dateOfBirth.value = null;
      birthdayController.text = '';
    } catch (e) {
      debugPrint('Error during sign out: $e');
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    // Navigate back to the Login page.
    router.go(Routes.loginPage);
  }
}
