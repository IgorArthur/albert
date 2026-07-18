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
    this.action,
    this.borderColor,
    this.titleColor,
    this.iconColor,
    this.iconBgColor,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? action;
  final Color? borderColor;
  final Color? titleColor;
  final Color? iconColor;
  final Color? iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : Border.all(color: Theme.of(context).dividerColor, width: 0.8),
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
                  color: iconBgColor ?? AppColors.primary100.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primary100,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title).overline(
                  color: titleColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
              ),
              // ignore: use_null_aware_elements
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
