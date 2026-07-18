import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/workouts/presentation/getx/workouts_controller.dart';
import 'package:albert/features/workouts/presentation/widgets/dashed_border_painter.dart';
import 'package:albert/features/workouts/presentation/widgets/exercise_draft_card.dart';
import 'package:albert/features/workouts/presentation/widgets/routine_icon_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddWorkoutSheet extends StatelessWidget {
  const AddWorkoutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutsController.to;
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: topPadding > 0 ? topPadding + 24 : 48,
        bottom: bottomPadding > 0 ? bottomPadding + 16 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.sheetTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceLight : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: isDark ? Colors.white : Colors.black, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Scrollable inputs
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // NAME
                  Text('workouts_name'.tr).overline(color: AppColors.neutral60),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: controller.newRoutineNameController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'workouts_name_hint'.tr,
                        hintStyle: const TextStyle(color: AppColors.neutral60),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ICON
                  Text('workouts_icon'.tr).overline(color: AppColors.neutral60),
                  const SizedBox(height: 8),
                  const RoutineIconSelector(),
                  const SizedBox(height: 24),
                  // EXERCISES header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('workouts_exercises'.tr).overline(color: AppColors.neutral60),
                      GestureDetector(
                        onTap: controller.addExerciseToDraft,
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: AppColors.primary100, size: 16),
                            const SizedBox(width: 4),
                            Text('workouts_add'.tr).overline(color: AppColors.primary100),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ── Biset banner (dashed, reactive) ──────────────────────
                  Obx(() {
                    final isPicking =
                        controller.pickingBisetIndex.value != null;
                    final borderColor = isPicking
                        ? AppColors.primary100
                        : AppColors.neutral30;
                    final bgColor = isPicking
                        ? AppColors.primary100.withValues(alpha: 0.08)
                        : Colors.transparent;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomPaint(
                          painter: DashedBorderPainter(
                            color: borderColor,
                            radius: 12,
                            strokeWidth: 1.2,
                            dashLength: 5,
                            gapLength: 4,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  color: isPicking
                                      ? AppColors.primary100
                                      : AppColors.neutral60,
                                  size: 15,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: isPicking
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Pick the pair',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary100,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Tap any dashed exercise below to link it as a biset.',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 10,
                                                color: AppColors.neutral60,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Tap the link icon on a card to pair exercises as a biset.',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 11,
                                            color: AppColors.neutral60,
                                          ),
                                        ),
                                ),
                                if (isPicking) ...
                                  [
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: controller.cancelBisetPicking,
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary100,
                                        ),
                                      ),
                                    ),
                                  ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                  // Exercise cards — biset pairs grouped in a grey dashed wrapper
                  Obx(() {
                    final exercises = controller.newRoutineExercises;
                    final links = controller.bisetLinks;

                    // Build a set of secondary indices so we can skip them
                    // (they will be rendered inside their primary's group).
                    final secondaryIndices = links.keys.toSet();

                    // Map secondary → primary for quick lookup
                    // links: { secondaryIdx: primaryIdx }
                    // We also need primary → secondary.
                    final primaryToSecondary = <int, int>{
                      for (final e in links.entries) e.value: e.key,
                    };

                    final widgets = <Widget>[];

                    for (var i = 0; i < exercises.length; i++) {
                      if (secondaryIndices.contains(i)) continue; // handled inside group

                      final secondaryIdx = primaryToSecondary[i];
                      final isPaired = secondaryIdx != null &&
                          secondaryIdx < exercises.length;

                      if (isPaired) {
                        // ── Biset group wrapper ──────────────────────────────
                        widgets.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CustomPaint(
                              painter: DashedBorderPainter(
                                color: Colors.grey.shade600,
                                radius: 20,
                                strokeWidth: 1.2,
                                dashLength: 6,
                                gapLength: 4,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // BISET label at the top of the group
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.link_rounded,
                                            size: 12,
                                            color: AppColors.primary100,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'BISET',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.4,
                                              color: AppColors.primary100,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Primary card
                                    ExerciseDraftCard(
                                      index: i,
                                      exercise: exercises[i],
                                      isGrouped: true,
                                    ),
                                    const SizedBox(height: 8),
                                    // Secondary card
                                    ExerciseDraftCard(
                                      index: secondaryIdx,
                                      exercise: exercises[secondaryIdx],
                                      isGrouped: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // ── Regular (unpaired) card ──────────────────────────
                        widgets.add(
                          ExerciseDraftCard(
                            index: i,
                            exercise: exercises[i],
                          ),
                        );
                      }
                    }

                    return Column(children: widgets);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Save button
          ElevatedButton(
            onPressed: () {
              if (controller.saveRoutine()) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F4221),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: Text(
              controller.saveButtonLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
