import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.titleColor,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String tag;
  final Color tagColor;
  final String title;
  final Color titleColor;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: gradient == null ? (backgroundColor ?? AppColors.surfaceCard) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tag).overline(color: tagColor),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
