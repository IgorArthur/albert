import 'package:albert/features/login/presentation/getx/login_controller.dart';
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _activeTab = 0; // 0: Body, 1: Account, 2: Settings

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
              const SizedBox(height: 20),

              // ── Custom Sliding Tab Bar ───────────────────────────────────
              _buildTabBar(),

              // ── Tab Contents ─────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: _activeTab == 0
                    ? _buildBodyTab(c, context)
                    : _activeTab == 1
                        ? _buildAccountTab(c, context)
                        : _buildSettingsTab(c, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral30, width: 1),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _activeTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? AppColors.primary100 : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Body',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _activeTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? AppColors.primary100 : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _activeTab = 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeTab == 2 ? AppColors.primary100 : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTab(ProfileController c, BuildContext context) {
    return Column(
      key: const ValueKey<int>(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Measurements Card ────────────────────────────────────────
        ProfileSectionCard(
          icon: Icons.straighten_rounded,
          title: 'profile_body_stats'.tr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Birthday Card ────────────────────────────────────────────
        ProfileSectionCard(
          icon: Icons.cake_outlined,
          title: 'BIRTHDAY',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date of birth').body2Bold(color: AppColors.neutral100),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => c.selectBirthday(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.neutral30, width: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            final hasBirthday = c.dateOfBirth.value != null;
                            return Text(
                              hasBirthday ? c.formattedBirthday : 'dd/mm/aaaa',
                              style: TextStyle(
                                color: hasBirthday
                                    ? AppColors.neutral100
                                    : AppColors.neutral60,
                                fontSize: 15,
                              ),
                            );
                          }),
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.neutral60,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Age summary container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral0,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral30, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary100.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.primary100,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Age',
                          style: TextStyle(
                            color: AppColors.neutral60,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                          c.age != null ? '${c.age}' : '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Save body info button
        _PrimaryButtonWithIcon(
          icon: Icons.shopping_bag_outlined,
          label: 'Save body info',
          onTap: c.saveBodyInfo,
        ),
      ],
    );
  }

  Widget _buildAccountTab(ProfileController c, BuildContext context) {
    return Obx(() {
      final isLoggedIn = c.email.value.isNotEmpty;
      final isEditing = c.isEditingProfile.value;

      return Column(
        key: const ValueKey<int>(1),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Auth card ───────────────────────────────────────────────
          isLoggedIn
              ? _buildConnectedGoogleCard(c)
              : _buildSignInCard(),
          const SizedBox(height: 16),

          // ── Profile info card ────────────────────────────────────────
          ProfileSectionCard(
            icon: Icons.person_outline_rounded,
            title: 'profile_edit_profile'.tr,
            action: isLoggedIn
                ? GestureDetector(
                    onTap: () {
                      if (isEditing) {
                        c.saveProfile();
                      } else {
                        c.isEditingProfile.value = true;
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isEditing ? Icons.check : Icons.edit_outlined,
                          color: AppColors.primary100,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isEditing ? 'Save' : 'Edit',
                          style: const TextStyle(
                            color: AppColors.primary100,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isLoggedIn) ...[
                  const Text(
                    'Auto-filled from your Google account. Tap Edit to override.',
                    style: TextStyle(
                      color: AppColors.neutral60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ProfileTextField(
                  label: 'Name',
                  controller: c.nameController,
                  hint: 'Athlete',
                  enabled: !isLoggedIn || isEditing,
                ),
                const SizedBox(height: 20),
                Text('profile_avatar'.tr).body2Bold(
                  color: (!isLoggedIn || isEditing)
                      ? AppColors.neutral100
                      : AppColors.neutral60,
                ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: (!isLoggedIn || isEditing) ? 1.0 : 0.5,
                  child: AbsorbPointer(
                    absorbing: isLoggedIn && !isEditing,
                    child: const ProfileAvatarPicker(),
                  ),
                ),
                if (!isLoggedIn) ...[
                  const SizedBox(height: 20),
                  _PrimaryButton(
                    label: 'profile_save_profile'.tr,
                    onTap: c.saveProfile,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildConnectedGoogleCard(ProfileController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral30, width: 0.8),
      ),
      child: Row(
        children: [
          const _GoogleLogo(size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Connected with Google',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.primary100,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your profile info syncs automatically.',
                  style: TextStyle(
                    color: AppColors.neutral60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: c.signOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.neutral60,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'profile_sign_out'.tr,
                  style: const TextStyle(
                    color: AppColors.neutral60,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral30, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign in for auto-sync',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Connect Google to fetch your name and avatar automatically — and unlock Albert.AI.',
            style: TextStyle(
              color: AppColors.neutral60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => LoginController.to.continueWithGoogle(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neutral30,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: AppColors.neutral30, width: 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GoogleLogo(size: 18),
                SizedBox(width: 10),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(ProfileController c, BuildContext context) {
    return Column(
      key: const ValueKey<int>(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Preferences Card ─────────────────────────────────────────
        ProfileSectionCard(
          icon: Icons.palette_outlined,
          title: 'PREFERENCES',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Units', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              const ProfileUnitToggle(),
              const SizedBox(height: 20),
              const Text('App theme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Obx(() => Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.neutral30, width: 0.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: c.appTheme.value,
                    dropdownColor: AppColors.surfaceCard,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral60),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    items: ['Light', 'Dark', 'System'].map((theme) {
                      return DropdownMenuItem<String>(
                        value: theme,
                        child: Text(theme),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        c.setAppTheme(val);
                      }
                    },
                  ),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Notifications Card ───────────────────────────────────────
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
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  ProfileNotificationTile(
                    title: 'profile_streak_alerts'.tr,
                    subtitle: 'profile_streak_alerts_sub'.tr,
                    value: c.streakAlerts.value,
                    onChanged: (v) => c.streakAlerts.value = v,
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  ProfileNotificationTile(
                    title: 'profile_albert_tips'.tr,
                    subtitle: 'profile_albert_tips_sub'.tr,
                    value: c.albertTips.value,
                    onChanged: (v) => c.albertTips.value = v,
                    enabled: true,
                  ),
                ],
              )),
        ),
        const SizedBox(height: 16),

        // ── Danger Zone Card ─────────────────────────────────────────
        ProfileSectionCard(
          icon: Icons.restart_alt_rounded,
          title: 'DANGER ZONE',
          borderColor: AppColors.error100.withValues(alpha: 0.3),
          titleColor: AppColors.error100,
          iconColor: AppColors.error100,
          iconBgColor: AppColors.error100.withValues(alpha: 0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => c.confirmReset(context),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Reset settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.neutral30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ],
          ),
        ),
      ],
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

class _PrimaryButtonWithIcon extends StatelessWidget {
  const _PrimaryButtonWithIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary100,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    );
  }
}



class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double length = size.width;
    final double arcThickness = length / 4.5;
    final double halfThickness = arcThickness / 2;
    final Rect bounds = Rect.fromLTWH(
      halfThickness,
      halfThickness,
      length - arcThickness,
      length - arcThickness,
    );
    final Offset center = bounds.center;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcThickness
      ..strokeCap = StrokeCap.butt;

    void drawArc(double startAngle, double sweepAngle, Color color) {
      canvas.drawArc(bounds, startAngle, sweepAngle, false, paint..color = color);
    }

    drawArc(3.5, 1.9, const Color(0xFFEA4335));
    drawArc(2.5, 1.0, const Color(0xFFFBBC05));
    drawArc(0.9, 1.6, const Color(0xFF34A853));
    drawArc(-0.18, 1.1, const Color(0xFF4285F4));

    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - halfThickness,
        bounds.right + halfThickness - 0.5,
        center.dy + halfThickness,
      ),
      paint
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.fill
        ..strokeWidth = 0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
