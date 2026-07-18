import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:albert/features/utils/colors/app_colors.dart';

class LoadingScreen extends StatefulWidget {
  final String message;

  const LoadingScreen({
    super.key,
    required this.message,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 12.0, end: 32.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissing the loader via back gestures
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Frosted Glass Effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated pulsing flame logo
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryGradientStart,
                                AppColors.primary100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary100.withValues(alpha: 0.4),
                                blurRadius: _glowAnimation.value,
                                spreadRadius: _glowAnimation.value / 6,
                                offset: Offset.zero,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.flame,
                              color: Colors.black,
                              size: 52,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  // Premium layout custom indicator
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary100),
                      strokeWidth: 3.5,
                      backgroundColor: AppColors.neutral30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Localized message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper method to display the loading screen overlay.
void showLoadingOverlay(BuildContext context, String message) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'LoadingOverlay',
    barrierColor: Colors.transparent, // Using BackdropFilter internally
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return LoadingScreen(message: message);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
