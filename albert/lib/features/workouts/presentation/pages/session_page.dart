import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/presentation/getx/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = SessionController.to;

    return PopScope(
      // Intercept hardware/gesture back — show finish dialog instead of popping.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ctrl.showFinishConfirmation(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          final session = ctrl.activeSession.value;
          if (session == null) return const SizedBox.shrink();

          final exercises = session.exercises;

          return Column(
            children: [
              // ── App bar ───────────────────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      // Back (triggers finish dialog)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: () => ctrl.showFinishConfirmation(context),
                      ),
                      // Centre: IN SESSION + routine name
                      Expanded(
                        child: Column(
                          children: [
                            Text('session_in_session'.tr)
                                .overline(color: AppColors.primary100),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  session.routineName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Right: timer + counter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ctrl.elapsedFormatted,
                            style: const TextStyle(
                              color: AppColors.primary100,
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ctrl.completedCount}/${ctrl.totalExercises}',
                            style: const TextStyle(
                              color: AppColors.neutral60,
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Progress bar ─────────────────────────────────────────────
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ctrl.progress,
                    minHeight: 3,
                    backgroundColor: AppColors.neutral30,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary100),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Exercise list ─────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  itemCount: exercises.length,
                  itemBuilder: (context, i) {
                    final ex = exercises[i];
                    final done = ctrl.completedIndices.contains(i);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => ctrl.toggleExercise(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: done
                                ? AppColors.surfaceLight
                                : AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: done
                                  ? AppColors.primary100.withValues(alpha: 0.4)
                                  : AppColors.neutral30,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Exercise info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name.isEmpty
                                          ? 'Exercise ${i + 1}'
                                          : ex.name,
                                      style: TextStyle(
                                        color: done
                                            ? AppColors.neutral60
                                            : Colors.white,
                                        fontFamily: 'Montserrat',
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        decoration: done
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        decorationColor: AppColors.neutral60,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _Chip(label: '${ex.sets} SETS'),
                                        const SizedBox(width: 8),
                                        _Chip(label: '${ex.reps} REPS'),
                                        if (ex.kg > 0) ...[
                                          const SizedBox(width: 8),
                                          _Chip(
                                              label:
                                                  '${ex.kg % 1 == 0 ? ex.kg.toInt() : ex.kg} KG'),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Checkbox circle
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done
                                      ? AppColors.primary100
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: done
                                        ? AppColors.primary100
                                        : AppColors.neutral60,
                                    width: 2,
                                  ),
                                ),
                                child: done
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 18)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Finish session button ─────────────────────────────────────
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 12, 32, 16),
                  child: GestureDetector(
                    onTap: () => ctrl.showFinishConfirmation(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryGradientStart,
                            AppColors.primary100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      alignment: Alignment.center,
                      child:
                          Text('session_finish'.tr).body2Bold(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Set/rep chip ──────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neutral30,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
