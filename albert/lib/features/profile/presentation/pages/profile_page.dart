import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/profile/presentation/widgets/profile_avatar_picker.dart';
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
              Text('PROFILE').overline(color: AppColors.primary100),
              const SizedBox(height: 4),
              Text('Your account').display(color: AppColors.neutral100),
              const SizedBox(height: 4),
              Text('Tune Albert to fit you.').body1(color: AppColors.neutral60),
              const SizedBox(height: 24),

              // ── Summary Card ─────────────────────────────────────────────
              const ProfileSummaryCard(),
              const SizedBox(height: 16),

              // ── Edit Profile ─────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.person_outline_rounded,
                title: 'EDIT PROFILE',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileTextField(
                      label: 'Name',
                      controller: c.nameController,
                      hint: 'Athlete',
                    ),
                    const SizedBox(height: 20),
                    Text('Avatar').body2Bold(color: AppColors.neutral100),
                    const SizedBox(height: 12),
                    const ProfileAvatarPicker(),
                    const SizedBox(height: 20),
                    _PrimaryButton(
                      label: 'Save profile',
                      onTap: c.saveProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Account ──────────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.email_outlined,
                title: 'ACCOUNT',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileTextField(
                      label: 'Email',
                      controller: c.emailController,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Albert v1 stores data locally on this device.',
                    ).caption(color: AppColors.neutral60),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Body Stats ───────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.straighten_rounded,
                title: 'BODY STATS',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            label: 'Height (cm)',
                            controller: c.heightController,
                            hint: '180',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ProfileTextField(
                            label: 'Weight (kg)',
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
                      label: 'Save body stats',
                      onTap: c.saveBodyStats,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Units ────────────────────────────────────────────────────
              const ProfileSectionCard(
                icon: Icons.balance_rounded,
                title: 'UNITS',
                child: ProfileUnitToggle(),
              ),
              const SizedBox(height: 16),

              // ── Notifications ────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.notifications_outlined,
                title: 'NOTIFICATIONS',
                child: Obx(() => Column(
                      children: [
                        ProfileNotificationTile(
                          title: 'Workout reminders',
                          subtitle: 'Nudge me on training days.',
                          value: c.workoutReminders.value,
                          onChanged: (v) => c.workoutReminders.value = v,
                        ),
                        const SizedBox(height: 16),
                        ProfileNotificationTile(
                          title: 'Streak alerts',
                          subtitle: "Don't let the streak die.",
                          value: c.streakAlerts.value,
                          onChanged: (v) => c.streakAlerts.value = v,
                        ),
                        const SizedBox(height: 16),
                        ProfileNotificationTile(
                          title: 'Albert tips',
                          subtitle: 'Occasional coaching insights.',
                          value: c.albertTips.value,
                          onChanged: (v) => c.albertTips.value = v,
                        ),
                      ],
                    )),
              ),
              const SizedBox(height: 16),

              // ── Reset ────────────────────────────────────────────────────
              ProfileSectionCard(
                icon: Icons.restart_alt_rounded,
                title: 'RESET',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SecondaryButton(
                      icon: Icons.replay_rounded,
                      label: 'Reset settings',
                      onTap: c.resetSettings,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: AppColors.neutral60, size: 16),
                        const SizedBox(width: 8),
                        Text('Sign out (coming soon)').caption(color: AppColors.neutral60),
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
