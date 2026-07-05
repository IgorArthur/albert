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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
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
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral30, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: controller.newRoutineNameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                  // Exercise cards
                  Obx(() => Column(
                        children: List.generate(
                          controller.newRoutineExercises.length,
                          (index) => ExerciseDraftCard(
                            index: index,
                            exercise: controller.newRoutineExercises[index],
                          ),
                        ),
                      )),
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
    );
  }
}
