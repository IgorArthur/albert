import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/profile/presentation/widgets/profile_avatar_picker.dart';
import 'package:albert/features/profile/presentation/widgets/profile_font_size_picker.dart';
import 'package:albert/features/profile/presentation/widgets/profile_language_selector.dart';
import 'package:albert/features/profile/presentation/widgets/profile_notification_tile.dart';
import 'package:albert/features/profile/presentation/widgets/profile_section_card.dart';
import 'package:albert/features/profile/presentation/widgets/profile_summary_card.dart';
import 'package:albert/features/profile/presentation/widgets/profile_text_field.dart';
import 'package:albert/features/profile/presentation/widgets/profile_unit_toggle.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileController.to;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPadding + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page Header ──────────────────────────────────────────────
              Text('profile_overline'.tr).overline(color: AppColors.primary100),
              const SizedBox(height: 4),
              Text('profile_title'.tr).display(color: AppColors.neutral100),
              const SizedBox(height: 4),
              Text('profile_subtitle'.tr).body1(color: AppColors.neutral60),
              const SizedBox(height: 24),

              // ── Summary Card ─────────────────────────────────────────────
              const ProfileSummaryCard(),
              const SizedBox(height: 16),

              // ── Edit Profile ─────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.person_outline_rounded,
                title: 'profile_edit_profile'.tr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileTextField(
                      label: 'profile_name'.tr,
                      controller: c.nameController,
                      hint: 'profile_name_hint'.tr,
                    ),
                    const SizedBox(height: 20),
                    Text('profile_avatar'.tr).body2Bold(color: AppColors.neutral100),
                    const SizedBox(height: 12),
                    const ProfileAvatarPicker(),
                    const SizedBox(height: 20),
                    _PrimaryButton(
                      label: 'profile_save_profile'.tr,
                      onTap: c.saveProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Account ──────────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.email_outlined,
                title: 'profile_account'.tr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileTextField(
                      label: 'profile_email'.tr,
                      controller: c.emailController,
                      hint: 'profile_email_hint'.tr,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _SecondaryButton(
                      icon: Icons.save_outlined,
                      label: 'profile_save_email'.tr,
                      onTap: c.saveEmail,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'profile_local_data'.tr,
                    ).caption(color: AppColors.neutral60),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Body Stats ───────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.straighten_rounded,
                title: 'profile_body_stats'.tr,
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            label: c.heightLabel,
                            controller: c.heightController,
                            hint: '180',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ProfileTextField(
                            label: c.weightLabel,
                            controller: c.weightController,
                            hint: '75',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SecondaryButton(
                      icon: Icons.save_outlined,
                      label: 'profile_save_body'.tr,
                      onTap: c.saveBodyStats,
                    ),
                  ],
                )),
              ),
              const SizedBox(height: 16),

              // ── Units ────────────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.balance_rounded,
                title: 'profile_units'.tr,
                child: const ProfileUnitToggle(),
              ),
              const SizedBox(height: 16),

              // ── Font Size ────────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.text_fields_rounded,
                title: 'profile_text_size'.tr,
                child: const ProfileFontSizePicker(),
              ),
              const SizedBox(height: 16),

              // ── Language ─────────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.language_rounded,
                title: 'profile_language'.tr,
                child: const ProfileLanguageSelector(),
              ),
              const SizedBox(height: 16),

              // ── Notifications ────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.notifications_outlined,
                title: 'profile_notifications'.tr,
                child: Obx(() => Column(
                      children: [
                        ProfileNotificationTile(
                          title: 'profile_workout_reminders'.tr,
                          subtitle: 'profile_workout_reminders_sub'.tr,
                          value: c.workoutReminders.value,
                          onChanged: (v) => c.workoutReminders.value = v,
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        ProfileNotificationTile(
                          title: 'profile_streak_alerts'.tr,
                          subtitle: 'profile_streak_alerts_sub'.tr,
                          value: c.streakAlerts.value,
                          onChanged: (v) => c.streakAlerts.value = v,
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        ProfileNotificationTile(
                          title: 'profile_albert_tips'.tr,
                          subtitle: 'profile_albert_tips_sub'.tr,
                          value: c.albertTips.value,
                          onChanged: (v) => c.albertTips.value = v,
                          enabled: false,
                        ),
                      ],
                    )),
              ),
              const SizedBox(height: 16),

              // ── Reset ────────────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.restart_alt_rounded,
                title: 'profile_reset'.tr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SecondaryButton(
                      icon: Icons.replay_rounded,
                      label: 'profile_reset_settings'.tr,
                      onTap: () => c.confirmReset(context),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: AppColors.neutral60, size: 16),
                        const SizedBox(width: 8),
                        Text('profile_sign_out'.tr).caption(color: AppColors.neutral60),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helpers (simple enough to stay local) ─────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary100,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.neutral60, size: 18),
        label: Text(label,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral100)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.neutral30),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      );
}
