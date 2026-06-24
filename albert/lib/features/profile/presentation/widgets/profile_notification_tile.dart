import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

/// A single notification toggle row with a title, subtitle and a Switch.
class ProfileNotificationTile extends StatelessWidget {
  const ProfileNotificationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title).body2Bold(color: AppColors.neutral100),
                const SizedBox(height: 2),
                Text(subtitle).caption(color: AppColors.neutral60),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.primary100,
            activeTrackColor: AppColors.primary100.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.neutral60,
            inactiveTrackColor: AppColors.neutral30,
          ),
        ],
      ),
    );
  }
}
