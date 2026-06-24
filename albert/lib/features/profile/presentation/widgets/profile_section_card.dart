import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

/// A reusable section card with an icon badge + title header and a [child] body.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary100.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary100, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title).overline(color: AppColors.neutral100),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
