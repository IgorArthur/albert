import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/presentation/getx/session_controller.dart';
import 'package:albert/features/workouts/presentation/widgets/dashed_border_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final ctrl = SessionController.to;

  @override
  void initState() {
    super.initState();
    // Start/resume counting only while this page is displayed.
    ctrl.onSessionPageShown();
  }

  @override
  void dispose() {
    // Screen closed while a session is still active → stop counting and
    // persist the current elapsed time for restore.
    ctrl.onSessionPageHidden();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      // Intercept hardware/gesture back — show finish dialog instead of popping.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (ctrl.completedCount == 0) {
            ctrl.cancelSession(context);
          } else {
            ctrl.showFinishConfirmation(context);
          }
        }
      },
      child: Scaffold(
        body: Obx(() {
          final session = ctrl.activeSession.value;
          if (session == null) return const SizedBox.shrink();

          final exercises = session.exercises;

          return Column(
            children: [
              // ── App bar ───────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 0),
                child: Row(
                  children: [
                    // Empty spacer to balance the counter on the right
                    const SizedBox(width: 40),
                    // Centre: IN SESSION + routine name
                    Expanded(
                      child: Column(
                        children: [
                          Text('session_in_session'.tr)
                              .overline(color: AppColors.primary100),
                          const SizedBox(height: 2),
                          Text(
                            session.routineName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ),
                      // Right: counter
                      SizedBox(
                        width: 40,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${ctrl.completedCount}/${ctrl.totalExercises}',
                            style: const TextStyle(
                              color: AppColors.neutral60,
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                child: Builder(builder: (context) {
                  // Build ordered blocks; biset partners share one block.
                  final seen = <int>{};
                  final blocks = <List<int>>[];
                  for (var i = 0; i < exercises.length; i++) {
                    if (seen.contains(i)) continue;
                    final group = ctrl.groupOf(i);
                    seen.addAll(group);
                    blocks.add(group);
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    itemCount: blocks.length,
                    itemBuilder: (context, b) {
                      final group = blocks[b];

                      // Obx per block: itemBuilder runs lazily, outside the
                      // parent Obx, so it must track completedIndices itself.
                      return Obx(() {
                        final done =
                            ctrl.completedIndices.contains(group.first);

                        if (group.length == 1) {
                          final i = group.first;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ExerciseCard(
                              index: i,
                              name: exercises[i].name,
                              sets: exercises[i].sets,
                              reps: exercises[i].reps,
                              kg: exercises[i].kg,
                              done: done,
                              onTap: () => ctrl.toggleExercise(i),
                            ),
                          );
                        }

                        // ── Biset group: dashed wrapper with stacked cards ──
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CustomPaint(
                            painter: DashedBorderPainter(
                              color: done
                                  ? AppColors.primary100.withValues(alpha: 0.6)
                                  : Colors.grey.shade600,
                              radius: 22,
                              strokeWidth: 1.2,
                              dashLength: 6,
                              gapLength: 4,
                            ),
                            child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => ctrl.toggleExercise(group.first),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header: BISET label + single group check
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 0, 10, 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.link_rounded,
                                            size: 12,
                                            color: AppColors.primary100),
                                        const SizedBox(width: 6),
                                        const Expanded(
                                          child: Text(
                                            'BISET',
                                            style: TextStyle(
                                              color: AppColors.primary100,
                                              fontFamily: 'Montserrat',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.4,
                                            ),
                                          ),
                                        ),
                                        _CheckCircle(done: done),
                                      ],
                                    ),
                                  ),
                                  for (var k = 0; k < group.length; k++) ...[
                                    if (k > 0) const SizedBox(height: 8),
                                    _ExerciseCard(
                                      index: group[k],
                                      name: exercises[group[k]].name,
                                      sets: exercises[group[k]].sets,
                                      reps: exercises[group[k]].reps,
                                      kg: exercises[group[k]].kg,
                                      done: done,
                                      showCheck: false,
                                      onTap: () =>
                                          ctrl.toggleExercise(group[k]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
              ),

              // ── Timer & Finish session button ────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(32, 12, 32, MediaQuery.of(context).padding.bottom + 16),
                child: Column(
                  children: [
                    // Timer with box and icon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceLight
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                      ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, color: AppColors.primary100, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              ctrl.elapsedFormatted,
                              style: const TextStyle(
                                color: AppColors.primary100,
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Button
                      GestureDetector(
                        onTap: () {
                          if (ctrl.completedCount == 0) {
                            ctrl.cancelSession(context);
                          } else {
                            ctrl.showFinishConfirmation(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: ctrl.completedCount == 0
                              ? BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                      color: AppColors.error100, width: 1.5),
                                  borderRadius: BorderRadius.circular(50),
                                )
                              : BoxDecoration(
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
                            ctrl.completedCount == 0
                                ? 'session_quit'.tr
                                : 'session_finish'.tr,
                            style: TextStyle(
                              color: ctrl.completedCount == 0
                                  ? AppColors.error100
                                  : Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Exercise card (info + checkbox) ─────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.index,
    required this.name,
    required this.sets,
    required this.reps,
    required this.kg,
    required this.done,
    required this.onTap,
    this.showCheck = true,
  });

  final int index;
  final String name;
  final int sets;
  final int reps;
  final double kg;
  final bool done;
  final VoidCallback onTap;

  /// False inside a biset group, which shows one shared check instead.
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: done ? AppColors.surfaceLight : AppColors.surfaceCard,
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
            Expanded(
              child: _ExerciseInfo(
                index: index,
                name: name,
                sets: sets,
                reps: reps,
                kg: kg,
                done: done,
              ),
            ),
            if (showCheck) ...[
              const SizedBox(width: 16),
              _CheckCircle(done: done),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Check circle ─────────────────────────────────────────────────────────────

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done});
  final bool done;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.primary100 : Colors.transparent,
        border: Border.all(
          color: done ? AppColors.primary100 : AppColors.neutral60,
          width: 2,
        ),
      ),
      child: done
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
  }
}

// ─── Exercise info (name + chips) ──────────────────────────────────────────

class _ExerciseInfo extends StatelessWidget {
  const _ExerciseInfo({
    required this.index,
    required this.name,
    required this.sets,
    required this.reps,
    required this.kg,
    required this.done,
  });

  final int index;
  final String name;
  final int sets;
  final int reps;
  final double kg;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? 'Exercise ${index + 1}' : name,
          style: TextStyle(
            color: done ? AppColors.neutral60 : Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            decoration:
                done ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: AppColors.neutral60,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Chip(label: '$sets SETS'),
            const SizedBox(width: 8),
            _Chip(label: '$reps REPS'),
            if (kg > 0) ...[
              const SizedBox(width: 8),
              _Chip(label: '${kg % 1 == 0 ? kg.toInt() : kg} KG'),
            ],
          ],
        ),
      ],
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
