import 'package:albert/features/login/presentation/getx/login_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginController.to;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(24.0, topPadding + 32.0, 24.0, bottomPadding + 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            
            // Flame Logo with peach/orange gradient
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryGradientStart,
                      AppColors.primary100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary100.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.flame,
                    color: Colors.black,
                    size: 44,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title: "Welcome to Albert"
            Text(
              'login_welcome'.tr,
              textAlign: TextAlign.center,
            ).display(),
            const SizedBox(height: 12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'login_subtitle'.tr,
                textAlign: TextAlign.center,
              ).body1(color: AppColors.neutral60),
            ),
            
            const Spacer(),

            // "Continue with Google" Button
            ElevatedButton(
              onPressed: () => controller.continueWithGoogle(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogo(size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'login_continue_google'.tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // OR Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'login_or'.tr,
                  ).caption(color: AppColors.neutral60),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // "Continue without login" Button
            OutlinedButton(
              onPressed: () => controller.continueWithoutLogin(),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black,
                side: BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'login_continue_without'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 24.0});

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
    
    // Inset bounds to fit the stroke within the canvas size
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

    // Google Brand Colors:
    // Red (top)
    drawArc(3.5, 1.9, const Color(0xFFEA4335));
    // Yellow (left)
    drawArc(2.5, 1.0, const Color(0xFFFBBC05));
    // Green (bottom)
    drawArc(0.9, 1.6, const Color(0xFF34A853));
    // Blue (right)
    drawArc(-0.18, 1.1, const Color(0xFF4285F4));

    // Draw the horizontal bar of the 'G'
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - halfThickness,
        bounds.right + halfThickness - 0.5, // extends to the outer edge of the stroked circle
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
