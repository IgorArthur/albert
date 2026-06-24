import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The top card showing avatar, name, email, level, streak and XP.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileController.to;

    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Avatar bubble
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGradientStart, AppColors.primary100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  c.selectedAvatar.value,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.displayName.value).subtitle1(color: AppColors.neutral100),
                    const SizedBox(height: 2),
                    Text(c.emailSubtitle).caption(color: AppColors.neutral60),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: AppColors.primary100, size: 14),
                        const SizedBox(width: 4),
                        Text(c.levelLabel).captionBold(color: AppColors.primary100),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.primary100, size: 14),
                        const SizedBox(width: 4),
                        Text(c.streakLabel).captionBold(color: AppColors.neutral60),
                        const SizedBox(width: 12),
                        Text(c.xpLabel).captionBold(color: AppColors.neutral60),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
