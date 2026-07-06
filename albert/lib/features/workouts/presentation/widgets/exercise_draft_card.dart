import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:albert/features/workouts/presentation/widgets/dashed_border_painter.dart';
import 'package:albert/features/workouts/presentation/widgets/exercise_number_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─── Exercise draft card ──────────────────────────────────────────────────────

class ExerciseDraftCard extends StatefulWidget {
  const ExerciseDraftCard({
    super.key,
    required this.index,
    required this.exercise,
    this.isGrouped = false,
  });

  final int index;
  final Exercise exercise;
  /// When true the card is inside a biset group wrapper — skip its own bottom margin.
  final bool isGrouped;

  @override
  State<ExerciseDraftCard> createState() => _ExerciseDraftCardState();
}

class _ExerciseDraftCardState extends State<ExerciseDraftCard> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = WorkoutsController.to;
    final exercise = widget.exercise;
    final idx = widget.index;

    return Obx(() {
      final pickingIdx = ctrl.pickingBisetIndex.value;
      final links = ctrl.bisetLinks;

      // ── Derive card state ────────────────────────────────────────────────────
      final isPrimary = pickingIdx == idx; // this card started the pick flow
      final isSecondary = links.containsKey(idx); // this card is the paired target
      final isPicking = pickingIdx != null;

      // Find whether this card is the primary (source) of an existing biset pair
      final secondaryKey = links.entries
          .where((e) => e.value == idx)
          .map((e) => e.key)
          .firstOrNull;
      final isPrimaryOfLink = secondaryKey != null;

      final isAvailableForPick = isPicking && !isPrimary && !isSecondary && !isPrimaryOfLink;

      // Label shown above the secondary card
      final primaryIdx = links[idx]; // null when this is not secondary
      final primaryEx =
          primaryIdx != null ? ctrl.newRoutineExercises[primaryIdx] : null;
      final primaryLabel = isSecondary
          ? ((primaryEx != null && primaryEx.name.trim().isNotEmpty)
              ? primaryEx.name.trim().toUpperCase()
              : 'EX ${(primaryIdx! + 1).toString().padLeft(2, '0')}')
          : '';

      // Label shown above the primary card (symmetric)
      final secondaryEx =
          secondaryKey != null ? ctrl.newRoutineExercises[secondaryKey] : null;
      final secondaryLabel = isPrimaryOfLink
          ? ((secondaryEx != null && secondaryEx.name.trim().isNotEmpty)
              ? secondaryEx.name.trim().toUpperCase()
              : 'EX ${(secondaryKey! + 1).toString().padLeft(2, '0')}')
          : '';

      // ── Link icon tap ────────────────────────────────────────────────────────
      void handleLinkTap() {
        if (isPrimary) {
          ctrl.cancelBisetPicking();
        } else if (isSecondary) {
          ctrl.unlinkBiset(idx);
        } else if (isAvailableForPick) {
          ctrl.linkBiset(idx);
        } else if (isPrimaryOfLink) {
          ctrl.unlinkBiset(secondaryKey);
        } else {
          ctrl.startPickingBiset(idx);
        }
      }

      // ── Visual states ────────────────────────────────────────────────────────
      final linkActive = isPrimary || isSecondary || isPrimaryOfLink;
      final linkIconColor =
          linkActive ? AppColors.primary100 : AppColors.neutral30;

      // ── Card inner content ───────────────────────────────────────────────────
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: index · name · [link icon] · [trash icon]
          Row(
            children: [
              Text(
                (idx + 1).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppColors.primary100,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'workouts_exercise_hint'.tr,
                    hintStyle: const TextStyle(color: AppColors.neutral60),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => exercise.name = val,
                ),
              ),
              // ── Biset link icon ──────────────────────────────────────────────
              GestureDetector(
                onTap: handleLinkTap,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.link_rounded,
                    size: 20,
                    color: linkIconColor,
                  ),
                ),
              ),
              // ── Delete icon (only when >1 exercise) ─────────────────────────
              if (ctrl.newRoutineExercises.length > 1)
                GestureDetector(
                  onTap: () => ctrl.removeExerciseFromDraft(idx),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.delete_outline,
                        color: AppColors.error100, size: 20),
                  ),
                ),
            ],
          ),
          // ── Divider + set/rep/weight inputs ─────────────────────────────────
          const Divider(color: AppColors.neutral30, height: 20, thickness: 0.5),
          Row(
            children: [
              ExerciseNumberInput(
                label: 'workouts_sets'.tr,
                initialValue: exercise.sets.toString(),
                onChanged: (val) => exercise.sets = int.tryParse(val) ?? 0,
              ),
              const SizedBox(width: 12),
              ExerciseNumberInput(
                label: 'workouts_reps'.tr,
                initialValue: exercise.reps.toString(),
                onChanged: (val) => exercise.reps = int.tryParse(val) ?? 0,
              ),
              const SizedBox(width: 12),
              ExerciseNumberInput(
                label: ProfileController.to.weightUnitDisplay,
                initialValue: exercise.kg % 1 == 0
                    ? exercise.kg.toInt().toString()
                    : exercise.kg.toString(),
                onChanged: (val) => exercise.kg = double.tryParse(val) ?? 0,
              ),
            ],
          ),
        ],
      );

      // ── Wrap content with the right border style ─────────────────────────────
      Widget card;
      if (isPrimary) {
        // Source card: bright orange dashed border
        card = CustomPaint(
          painter: const DashedBorderPainter(
            color: AppColors.primary100,
            radius: 16,
            strokeWidth: 1.5,
            dashLength: 5,
            gapLength: 4,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: content,
          ),
        );
      } else if (isAvailableForPick) {
        // Available card: dark orange background + orange dashed border.
        card = CustomPaint(
          foregroundPainter: const DashedBorderPainter(
            color: Color(0xFFE65100),
            radius: 16,
            strokeWidth: 1.5,
            dashLength: 5,
            gapLength: 4,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: content,
          ),
        );
      } else {
        // Linked cards (isSecondary / isPrimaryOfLink) and plain cards
        // both use the exact same neutral border — no orange on linked cards.
        card = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral30, width: 0.5),
          ),
          child: content,
        );
      }

      // Wrap available-to-pick cards so tapping anywhere completes the link.
      if (isAvailableForPick) {
        card = GestureDetector(
          onTap: () => ctrl.linkBiset(idx),
          behavior: HitTestBehavior.opaque,
          child: card,
        );
      }

      // ── Labels above the card + spacing below ────────────────────────────────
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          card,
          if (!widget.isGrouped) const SizedBox(height: 16),
        ],
      );
    });
  }
}
