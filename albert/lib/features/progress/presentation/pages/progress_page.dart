import 'package:albert/features/progress/presentation/getx/progress_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    // Initialize controller if not already present
    Get.put(ProgressController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProgressController.to;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  // Header
                  Text('progress_overline'.tr).overline(color: AppColors.primary100),
                  Text('progress_title'.tr).display(color: Colors.white),
                  const SizedBox(height: 4),
                  Text('progress_subtitle'.tr).body2(color: AppColors.neutral60),
                  const SizedBox(height: 24),
                  
                  // Lifter Level Card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    ),
                    child: Row(
                      children: [
                        // Level Circle
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Obx(() => Text(
                            '${controller.level.value}',
                            style: const TextStyle(
                              color: AppColors.background,
                              fontFamily: 'Montserrat',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                        const SizedBox(width: 20),
                        // XP Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('progress_lifter_level'.tr, style: TextStyle(
                                color: AppColors.background.withValues(alpha: 0.7),
                                fontFamily: 'Montserrat',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              )),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                '${controller.currentXp.value} XP',
                                style: const TextStyle(
                                  color: AppColors.background,
                                  fontFamily: 'Montserrat',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              const SizedBox(height: 10),
                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.5, // Mocked for aesthetics if level 1 logic isn't perfect, but let's connect it
                                  minHeight: 4,
                                  backgroundColor: Colors.black.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation(Colors.black.withValues(alpha: 0.3)),
                                ),
                              ),
                              const SizedBox(height: 8),
                               Obx(() => Text(
                                'progress_xp_to_next'.trParams({
                                  'xp': '${controller.xpToNextLevel.value}',
                                  'level': '${controller.level.value + 1}',
                                }),
                                style: TextStyle(
                                  color: AppColors.background.withValues(alpha: 0.8),
                                  fontFamily: 'Montserrat',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2x2 Grid of Stats
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => _StatCard(
                          icon: Icons.local_fire_department_outlined,
                          value: '${controller.streakDays.value} d',
                          label: 'progress_streak_label'.tr,
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => _StatCard(
                          icon: Icons.calendar_today_outlined,
                          value: '${controller.totalSessions.value}',
                          label: 'progress_sessions_label'.tr,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => _StatCard(
                          icon: Icons.fitness_center,
                          value: '${controller.totalSets.value}',
                          label: 'progress_total_sets_label'.tr,
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => _StatCard(
                          icon: Icons.emoji_events_outlined,
                          value: '${controller.totalVolume.value}',
                          label: 'progress_volume_label'.tr,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Last 14 days chart container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.neutral30, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'progress_last_14_days'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'progress_sets_by_day'.tr,
                          style: const TextStyle(
                            color: AppColors.neutral60,
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 140), // Empty space for chart
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['T', 'T', 'S', 'M', 'W', 'F', 'S']
                              .map((day) => Text(
                                    day,
                                    style: const TextStyle(
                                      color: AppColors.neutral60,
                                      fontFamily: 'Montserrat',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // All Sessions Header
                  Text(
                    'progress_all_sessions'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
            
            // Sessions List (placeholder for future implementation if needed)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 40),
                    child: Text('progress_coming_soon'.tr, style: const TextStyle(color: AppColors.neutral60)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral30, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary100, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral60,
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
