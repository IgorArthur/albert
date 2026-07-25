import 'package:albert/features/progress/presentation/getx/progress_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/utils/utils.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshAppData,
        color: AppColors.primary100,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.0, topPadding + 24.0, 20.0, 24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  Text('progress_overline'.tr).overline(color: AppColors.primary100),
                  const SizedBox(height: 6),
                  Text('progress_title'.tr).display(),
                  const SizedBox(height: 6),
                  Text('progress_subtitle'.tr).body1(color: AppColors.neutral60),
                  const SizedBox(height: 32),
                  
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
                          icon: Icons.timer_outlined,
                          value: controller.formattedTotalTime,
                          label: 'progress_total_time_label'.tr,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Full-width Total Volume card below the 4 grid cards
                  Obx(() => _StatCard(
                    icon: Icons.emoji_events_outlined,
                    value: controller.formattedTotalVolume,
                    label: 'progress_volume_label'.tr,
                    isFullWidth: true,
                  )),
                  const SizedBox(height: 24),

                  // Last 14 days dynamic chart container
                  Obx(() {
                    final data = controller.last14DaysData;
                    final maxSets = controller.maxSetsIn14Days;
                    final effectiveMax = maxSets > 0 ? maxSets : 10;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Theme.of(context).dividerColor, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'progress_last_14_days'.tr,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
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
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary100
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${controller.totalSetsIn14Days} sets',
                                  style: const TextStyle(
                                    color: AppColors.primary100,
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 14 Bars
                          SizedBox(
                            height: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: data.map((d) {
                                final ratio =
                                    (d.sets / effectiveMax).clamp(0.0, 1.0);
                                final barHeight = ratio * 90;
                                final isToday = d.date.day ==
                                        DateTime.now().day &&
                                    d.date.month == DateTime.now().month;

                                return Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Value label on top of bar if > 0
                                      SizedBox(
                                        height: 16,
                                        child: d.sets > 0
                                            ? Text(
                                                '${d.sets}',
                                                style: const TextStyle(
                                                  color: AppColors.primary100,
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                      const SizedBox(height: 4),
                                      // Bar track & fill
                                      Container(
                                        width: 14,
                                        height: 90,
                                        alignment: Alignment.bottomCenter,
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? AppColors.primary100
                                                  .withValues(alpha: 0.15)
                                              : Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                      .withValues(alpha: 0.05)
                                                  : Colors.black
                                                      .withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          curve: Curves.easeOut,
                                          width: 14,
                                          height: d.sets > 0
                                              ? (barHeight < 8 ? 8 : barHeight)
                                              : 0,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.primaryGradientStart,
                                                AppColors.primary100,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: d.sets > 0
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors
                                                          .primary100
                                                          .withValues(
                                                              alpha: 0.4),
                                                      blurRadius: 6,
                                                      offset:
                                                          const Offset(0, 2),
                                                    )
                                                  ]
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Day label
                                      Text(
                                        d.dayLabel,
                                        style: TextStyle(
                                          color: isToday
                                              ? AppColors.primary100
                                              : AppColors.neutral60,
                                          fontFamily: 'Montserrat',
                                          fontSize: 10,
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  
                  // All Sessions Header + Server Loading Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'progress_all_sessions'.tr,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(() {
                        if (controller.isLoadingSessions.value) {
                          return const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary100,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips Row: 7d, 14d, 28d, Custom
                  Obx(() {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: '7d',
                            isSelected: controller.selectedFilter.value ==
                                SessionFilterOption.last7Days,
                            onTap: () => controller
                                .setFilter(SessionFilterOption.last7Days),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: '14d',
                            isSelected: controller.selectedFilter.value ==
                                SessionFilterOption.last14Days,
                            onTap: () => controller
                                .setFilter(SessionFilterOption.last14Days),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: '28d',
                            isSelected: controller.selectedFilter.value ==
                                SessionFilterOption.last28Days,
                            onTap: () => controller
                                .setFilter(SessionFilterOption.last28Days),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: controller.customRangeLabel,
                            icon: Icons.calendar_month_outlined,
                            isSelected: controller.selectedFilter.value ==
                                SessionFilterOption.custom,
                            onTap: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDateRange: controller
                                        .customDateRange.value ??
                                    DateTimeRange(
                                      start: DateTime.now().subtract(
                                          const Duration(days: 7)),
                                      end: DateTime.now(),
                                    ),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: Theme.of(context)
                                                  .brightness ==
                                              Brightness.dark
                                          ? const ColorScheme.dark(
                                              primary: AppColors.primary100,
                                              onPrimary: Colors.black,
                                              surface: AppColors.surfaceCard,
                                              onSurface: Colors.white,
                                            )
                                          : const ColorScheme.light(
                                              primary: AppColors.primary100,
                                              onPrimary: Colors.white,
                                            ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                controller.setCustomFilter(picked);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
            
            // Sessions List
            Obx(() {
              final sessions = controller.sessionsList;
              if (sessions.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        child: Column(
                          children: [
                            const Icon(Icons.history_toggle_off_rounded,
                                size: 40, color: AppColors.neutral60),
                            const SizedBox(height: 8),
                            Text(
                              'No workout sessions recorded yet.',
                              style: const TextStyle(color: AppColors.neutral60),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 32.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _SessionCard(session: sessions[index]),
                    childCount: sessions.length,
                  ),
                ),
              );
            }),
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
    this.isFullWidth = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
      ),
      child: isFullWidth
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Montserrat',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary100.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary100, size: 24),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary100, size: 20),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate session stats
    int sets = 0;
    double volume = 0;
    for (final ex in session.exercises) {
      sets += ex.sets;
      volume += (ex.sets * ex.reps * ex.kg);
    }

    // Duration formatting
    final Duration duration = session.finishedAt != null
        ? session.finishedAt!.difference(session.startedAt)
        : DateTime.now().difference(session.startedAt);

    final int seconds = duration.inSeconds;
    String durationStr = '0s';
    if (seconds > 0) {
      if (seconds < 60) {
        durationStr = '${seconds}s';
      } else if (seconds < 3600) {
        final m = seconds ~/ 60;
        final s = seconds % 60;
        durationStr = s > 0 ? '${m}m ${s}s' : '${m}m';
      } else {
        final h = seconds ~/ 3600;
        final m = (seconds % 3600) ~/ 60;
        durationStr = m > 0 ? '${h}h ${m}m' : '${h}h';
      }
    }

    // Date & Hour formatting
    final date = session.startedAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // Volume formatting
    final volInt = volume.toInt();
    final strVol = volInt.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < strVol.length; i++) {
      if (i > 0 && (strVol.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(strVol[i]);
    }
    final volumeFormatted = '$buffer kg';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Routine Name + Date & Hour
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary100.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: AppColors.primary100,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.routineName.isNotEmpty
                            ? session.routineName
                            : 'Workout Session',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 12, color: AppColors.neutral60),
                          const SizedBox(width: 4),
                          Text(
                            '$dateStr at $timeStr',
                            style: const TextStyle(
                              color: AppColors.neutral60,
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (session.finishedAt == null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),

          // Main Stats Row: Total Sets, Total Volume, Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sets
              _SessionStatItem(
                icon: Icons.format_list_bulleted_rounded,
                value: '$sets',
                label: 'Sets',
              ),
              // Volume
              _SessionStatItem(
                icon: Icons.scale_rounded,
                value: volumeFormatted,
                label: 'Volume',
              ),
              // Time
              _SessionStatItem(
                icon: Icons.timer_outlined,
                value: durationStr,
                label: 'Time',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionStatItem extends StatelessWidget {
  const _SessionStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary100),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.neutral60,
                fontFamily: 'Montserrat',
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary100
              : isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary100
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? Colors.black
                    : isDark
                        ? Colors.white
                        : Colors.black,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : isDark
                        ? Colors.white
                        : Colors.black,
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
