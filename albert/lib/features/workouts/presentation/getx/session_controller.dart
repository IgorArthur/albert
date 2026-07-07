import 'dart:async';

import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/go_router/files/routes.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class SessionController extends GetxController {
  static SessionController get to => Get.find();

  // ── State ─────────────────────────────────────────────────────────────────

  final Rx<WorkoutSession?> activeSession = Rx(null);
  final RxSet<int> completedIndices = <int>{}.obs;
  final RxInt elapsedSeconds = 0.obs;

  Timer? _timer;

  // ── Getters ───────────────────────────────────────────────────────────────

  bool get isActive => activeSession.value != null;

  String get elapsedFormatted {
    final m = (elapsedSeconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get totalExercises => activeSession.value?.exercises.length ?? 0;
  int get completedCount => completedIndices.length;

  double get progress =>
      totalExercises == 0 ? 0 : completedCount / totalExercises;

  // ── Confirmation modal ────────────────────────────────────────────────────

  void showStartConfirmation(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _StartConfirmationDialog(routine: routine),
    );
  }

  // ── Session lifecycle ─────────────────────────────────────────────────────

  void startSession(BuildContext context, Routine routine) {
    Navigator.of(context, rootNavigator: true).pop(); // close dialog

    final cloned = routine.exercises
        .map((e) => Exercise(name: e.name, sets: e.sets, reps: e.reps, kg: e.kg))
        .toList();

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineId: routine.id,
      routineName: routine.name,
      startedAt: DateTime.now(),
      exercises: cloned,
    );

    boxWorkoutSessions.put(session.id, session);

    activeSession.value = session;
    completedIndices.clear();
    elapsedSeconds.value = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });

    context.push(Routes.sessionPage);
  }

  void toggleExercise(int index) {
    if (completedIndices.contains(index)) {
      completedIndices.remove(index);
    } else {
      completedIndices.add(index);
    }
  }

  /// Shows the finish confirmation dialog.
  void showFinishConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'session_finish_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            fontSize: 18,
          ),
        ),
        content: Text(
          'session_finish_body'.tr,
          style: const TextStyle(
            color: AppColors.neutral60,
            fontFamily: 'Montserrat',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'session_cancel'.tr,
              style: const TextStyle(color: AppColors.neutral60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              finishSession(context);
            },
            child: Text(
              'session_confirm'.tr,
              style: const TextStyle(
                color: AppColors.primary100,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void finishSession(BuildContext context) {
    _timer?.cancel();
    _timer = null;

    final session = activeSession.value;
    if (session != null) {
      session.finishedAt = DateTime.now();
      boxWorkoutSessions.put(session.id, session);
    }

    activeSession.value = null;
    completedIndices.clear();
    elapsedSeconds.value = 0;

    context.pop();
  }

  void cancelSession(BuildContext context) {
    _timer?.cancel();
    _timer = null;

    final session = activeSession.value;
    if (session != null) {
      // Remove it from the database since it's cancelled
      boxWorkoutSessions.delete(session.id);
    }

    activeSession.value = null;
    completedIndices.clear();
    elapsedSeconds.value = 0;

    context.pop();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

// ─── Start confirmation dialog ────────────────────────────────────────────────

class _StartConfirmationDialog extends StatelessWidget {
  const _StartConfirmationDialog({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final ctrl = SessionController.to;
    final count = routine.exercises.length;

    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Routine icon avatar
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
                routine.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              'session_start_title'.trParams({'name': routine.name}),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Body
            Text(
              'session_start_body'.trParams({'count': '$count'}),
              style: const TextStyle(
                color: AppColors.neutral60,
                fontFamily: 'Montserrat',
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Timer warning pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppColors.primary100,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'session_timer_note'.tr,
                    style: const TextStyle(
                      color: AppColors.primary100,
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'session_cancel'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Start session
                Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.startSession(context, routine),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      child: Text(
                        'session_start_btn'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
