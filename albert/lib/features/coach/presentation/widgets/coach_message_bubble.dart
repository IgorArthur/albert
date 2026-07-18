import 'package:flutter/material.dart';
import '../../../utils/colors/app_colors.dart';
import '../../domain/entities/coach_message.dart';

class CoachMessageBubble extends StatelessWidget {
  final CoachMessage message;
  const CoachMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.primary100
                : (isDark ? AppColors.surfaceCard : Colors.grey.shade200),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(20),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: isUser
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black87),
              fontSize: 14.5,
            ),
          ),
        ),
      ),
    );
  }
}
