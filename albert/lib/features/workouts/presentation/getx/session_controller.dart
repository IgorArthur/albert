import 'dart:async';

import 'package:albert/features/progress/presentation/getx/progress_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/go_router/files/routes.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
import 'package:albert/features/workouts/domain/entities/workout.dart';
import 'package:albert/features/workouts/domain/usecases/add_workout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SessionController extends GetxController with WidgetsBindingObserver {
  static SessionController get to => Get.find();

  static const _snapshotKey = 'snapshot';

  // ── State ─────────────────────────────────────────────────────────────────

  final Rx<WorkoutSession?> activeSession = Rx(null);
  final RxSet<int> completedIndices = <int>{}.obs;
  final RxInt elapsedSeconds = 0.obs;

  Timer? _timer;
  bool _restorePromptShown = false;

  /// Whether the session page is currently on screen. The timer only runs
  /// while the page is visible and the app is in the foreground.
  bool _pageVisible = false;

  /// The session the user should resume: the one running in memory, or the
  /// most recent unfinished session found in storage. Null when none.
  final Rx<WorkoutSession?> pendingSession = Rx(null);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _refreshPending();
    boxWorkoutSessions.listenable().addListener(_refreshPending);
    ever(activeSession, (_) => _refreshPending());
  }

  List<WorkoutSession> _unfinishedSessions() {
    final list = boxWorkoutSessions.values
        .whereType<WorkoutSession>()
        .where((s) => s.finishedAt == null)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt)); // newest first
    return list;
  }

  void _refreshPending() {
    final unfinished = _unfinishedSessions();
    pendingSession.value = activeSession.value ??
        (unfinished.isNotEmpty ? unfinished.first : null);
  }

  /// Removes every unfinished session except [keepId] (locally and remotely).
  void _discardOtherUnfinished(String? keepId) {
    for (final s in _unfinishedSessions()) {
      if (s.id != keepId) _deleteSession(s.id);
    }
  }

  void _deleteSession(String id) {
    boxWorkoutSessions.delete(id);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(id)
        .delete()
        .catchError((e) => debugPrint('Error deleting session $id: $e'));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _pauseTimer();
      saveSnapshot();
    } else if (state == AppLifecycleState.resumed && _pageVisible) {
      _resumeTimer();
    }
  }

  // ── Visibility-driven timer ───────────────────────────────────────────────

  /// Called by the session page when it becomes visible.
  void onSessionPageShown() {
    _pageVisible = true;
    _resumeTimer();
  }

  /// Called by the session page when it is disposed (no longer displayed).
  void onSessionPageHidden() {
    _pageVisible = false;
    _pauseTimer();
    updateSession();
  }

  /// Stops counting. The elapsed time is kept in [elapsedSeconds].
  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resumeTimer() {
    if (!isActive || _timer != null) return;
    _startTimer();
  }

  // ── Snapshot persistence ──────────────────────────────────────────────────

  /// Saves the current in-progress session state so it can be restored later.
  Future<void> saveSnapshot() async {
    final session = activeSession.value;
    if (session == null) return;
    await boxWorkoutSessions.put(session.id, session);
    await boxActiveSession.put(_snapshotKey, {
      'sessionId': session.id,
      'completedIndices': completedIndices.toList(),
      'elapsedSeconds': elapsedSeconds.value,
    });
  }

  /// Saves the in-progress session with its current elapsed time, locally
  /// (snapshot) and remotely. Called on page dispose and exercise toggle.
  Future<void> updateSession() async {
    final session = activeSession.value;
    if (session == null) return;
    await saveSnapshot();
    await _syncSessionToRemote(session, status: 'in_progress');
  }

  Future<void> _clearSnapshot() async {
    await boxActiveSession.delete(_snapshotKey);
  }

  /// At app start (Home), alert the user if there's an active session.
  void promptRestoreIfNeeded(BuildContext context) {
    if (_restorePromptShown || isActive) return;
    _restorePromptShown = true;
    final session = pendingSession.value;
    if (session == null) {
      _clearSnapshot();
      return;
    }
    _showActiveSessionDialog(
      context,
      session,
      title: 'session_restore_title'.tr,
      body: 'session_restore_body'.trParams({'name': session.routineName}),
      allowDiscard: true,
    );
  }

  void _showActiveSessionDialog(
    BuildContext context,
    WorkoutSession session, {
    required String title,
    required String body,
    required bool allowDiscard,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.timer_outlined, color: AppColors.primary100),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          body,
          style: const TextStyle(
            color: AppColors.neutral60,
            fontFamily: 'Montserrat',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (allowDiscard) {
                _deleteSession(session.id);
                _discardOtherUnfinished(null);
                _clearSnapshot();
              }
            },
            child: Text(
              allowDiscard
                  ? 'session_restore_discard'.tr
                  : 'session_cancel'.tr,
              style: const TextStyle(color: AppColors.neutral60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              resumePendingSession(context);
            },
            child: Text(
              'session_restore_resume'.tr,
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

  /// Opens the pending session (in memory or restored from storage).
  void resumePendingSession(BuildContext context) {
    if (isActive) {
      context.push(Routes.sessionPage);
      return;
    }
    final session = pendingSession.value;
    if (session == null) return;

    final raw = boxActiveSession.get(_snapshotKey);
    final matches = raw is Map && raw['sessionId'] == session.id;
    final completed = matches
        ? (raw['completedIndices'] as List? ?? []).cast<int>()
        : <int>[];
    final elapsed = matches
        ? (raw['elapsedSeconds'] as num? ?? 0).toInt()
        : DateTime.now().difference(session.startedAt).inSeconds;

    _discardOtherUnfinished(session.id);

    activeSession.value = session;
    completedIndices
      ..clear()
      ..addAll(completed.where((i) => i < session.exercises.length));
    elapsedSeconds.value = elapsed;
    saveSnapshot(); // timer starts when the session page is shown
    context.push(Routes.sessionPage);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

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

  // ── Confirmation modal ──────────────────────────────────────────────────

  void showStartConfirmation(BuildContext context, Routine routine) {
    // Only one session may be active at a time.
    final pending = pendingSession.value;
    if (pending != null) {
      _showActiveSessionDialog(
        context,
        pending,
        title: 'session_active_block_title'.tr,
        body: 'session_active_block_body'
            .trParams({'name': pending.routineName}),
        allowDiscard: false,
      );
      return;
    }
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _StartConfirmationDialog(routine: routine),
    );
  }

  // ── Session lifecycle ─────────────────────────────────────────────────────

  void startSession(BuildContext context, Routine routine) async {
    // Capture the router before closing the dialog / awaiting: the dialog's
    // context is disposed once it is popped.
    final router = GoRouter.of(context);
    Navigator.of(context, rootNavigator: true).pop(); // close dialog

    // Only one session may be in progress at a time.
    if (pendingSession.value != null) {
      showStartConfirmation(context, routine); // shows the "active" dialog
      return;
    }

    final cloned = routine.exercises
        .map((e) => Exercise(
            name: e.name,
            sets: e.sets,
            reps: e.reps,
            kg: e.kg,
            bisetWith: e.bisetWith))
        .toList();

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineId: routine.id,
      routineName: routine.name,
      startedAt: DateTime.now(),
      exercises: cloned,
    );

    await boxWorkoutSessions.put(session.id, session);

    activeSession.value = session;
    completedIndices.clear();
    elapsedSeconds.value = 0;

    saveSnapshot(); // timer starts when the session page is shown

    // 2. Sync user progress to Firestore when starting a session
    if (Get.isRegistered<ProgressController>()) {
      ProgressController.to.syncProgressToFirestore();
    }

    router.push(Routes.sessionPage);
  }

  /// Returns the indices that belong to the same biset group as [index]
  /// (just [index] itself when it isn't part of a biset). Links are followed
  /// in both directions, so chained/reversed links still form one group.
  List<int> groupOf(int index) {
    final exercises = activeSession.value?.exercises ?? const <Exercise>[];
    if (index < 0 || index >= exercises.length) return [index];

    final adjacency = <int, Set<int>>{};
    for (var i = 0; i < exercises.length; i++) {
      final p = exercises[i].bisetWith;
      if (p == null || p == i || p < 0 || p >= exercises.length) continue;
      adjacency.putIfAbsent(i, () => {}).add(p);
      adjacency.putIfAbsent(p, () => {}).add(i);
    }

    final group = <int>{index};
    final queue = [index];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      for (final n in adjacency[current] ?? const <int>{}) {
        if (group.add(n)) queue.add(n);
      }
    }
    return group.toList()..sort();
  }

  void toggleExercise(int index) {
    final group = groupOf(index);
    if (completedIndices.contains(index)) {
      completedIndices.removeAll(group);
    } else {
      completedIndices.addAll(group);
    }
    updateSession();
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

  void finishSession(BuildContext context) async {
    final router = GoRouter.of(context); // capture before any await
    _timer?.cancel();
    _timer = null;

    final session = activeSession.value;
    if (session != null) {
      session.finishedAt = DateTime.now();
      await boxWorkoutSessions.put(session.id, session);

      // 1. Sync completed session to Firestore
      _syncSessionToRemote(session, status: 'completed');

      // 2. Save each exercise in the completed session as a Workout log
      for (var i = 0; i < session.exercises.length; i++) {
        final exercise = session.exercises[i];
        if (exercise.name.isNotEmpty) {
          final workout = Workout(
            id: '${session.id}_$i',
            exerciseName: exercise.name,
            sets: exercise.sets,
            reps: exercise.reps,
            weightKg: exercise.kg,
            date: session.finishedAt ?? DateTime.now(),
          );
          try {
            if (Get.isRegistered<AddWorkout>()) {
              await Get.find<AddWorkout>().call(AddWorkoutParams(workout: workout));
            }
          } catch (e) {
            debugPrint('Error saving workout to Firestore on finish session: $e');
          }
        }
      }

      // 3. Sync updated progress stats to Firestore
      if (Get.isRegistered<ProgressController>()) {
        ProgressController.to.syncProgressToFirestore();
      }
    }

    activeSession.value = null;
    completedIndices.clear();
    elapsedSeconds.value = 0;
    _clearSnapshot();

    if (router.canPop()) router.pop();
  }

  Future<void> _syncSessionToRemote(WorkoutSession session, {required String status}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .doc(session.id);

      await doc.set({
        'id': session.id,
        'routineId': session.routineId,
        'routineName': session.routineName,
        'startedAt': session.startedAt.toIso8601String(),
        'finishedAt': session.finishedAt?.toIso8601String(),
        'status': status,
        'completedIndices': completedIndices.toList(),
        'elapsedSeconds': elapsedSeconds.value,
        'exercises': session.exercises
            .map((e) => {
                  'name': e.name,
                  'sets': e.sets,
                  'reps': e.reps,
                  'kg': e.kg,
                  if (e.bisetWith != null) 'bisetWith': e.bisetWith,
                })
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('Workout session $status synced to Firestore: ${session.id}');
    } catch (e) {
      debugPrint('Error syncing workout session $status to Firestore: $e');
    }
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
    _clearSnapshot();

    context.pop();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
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
