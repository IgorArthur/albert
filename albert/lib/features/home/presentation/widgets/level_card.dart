import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.streakDays,
    required this.sessionsLogged,
    super.key,
  });

  final int level;
  final int currentXp;
  final int maxXp;
  final int streakDays;
  final int sessionsLogged;

  @override
  Widget build(BuildContext context) {
    final xpFraction = maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Level and XP Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("LEVEL").overline(color: AppColors.neutral60),
                  const SizedBox(height: 4),
                  Text("$level").display(color: AppColors.neutral100),
                  const SizedBox(height: 6),
                  Text("$currentXp / $maxXp XP").caption(color: AppColors.neutral60),
                ],
              ),
              // Right Column: Streak Badge & Sessions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary100.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.primary100,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text("$streakDays day streak").captionBold(color: AppColors.primary100),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("$sessionsLogged sessions logged").caption(color: AppColors.neutral60),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // XP Progress Bar
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.neutral30,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (xpFraction * 1000).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((1.0 - xpFraction) * 1000).toInt(),
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
