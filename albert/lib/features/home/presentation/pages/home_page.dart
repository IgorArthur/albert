import 'package:albert/features/home/presentation/getx/home_controller.dart';
import 'package:albert/features/home/presentation/widgets/level_card.dart';
import 'package:albert/features/home/presentation/widgets/quick_action_card.dart';
import 'package:albert/features/home/presentation/widgets/routine_card.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Welcome Header Section
                  Text("WELCOME BACK").overline(color: AppColors.primary100),
                  const SizedBox(height: 4),
                  Text("Let's lift, athlete.").display(color: AppColors.neutral100),
                  const SizedBox(height: 4),
                  Text("Albert is ready to coach your next set.").body1(color: AppColors.neutral60),
                  
                  const SizedBox(height: 28),
                  // Athlete Level Card
                  LevelCard(
                    level: controller.level,
                    currentXp: controller.currentXp,
                    maxXp: controller.maxXp,
                    streakDays: controller.streakDays,
                    sessionsLogged: controller.sessionsLogged,
                  ),

                  const SizedBox(height: 24),
                  // Quick Actions Grid (Start Workout & Coach Albert)
                  Row(
                    children: [
                      QuickActionCard(
                        icon: Icons.fitness_center_rounded,
                        iconColor: Colors.black.withValues(alpha: 0.7),
                        tag: "START NOW",
                        tagColor: Colors.black.withValues(alpha: 0.6),
                        title: "🔥 ${controller.nextWorkoutName}",
                        titleColor: Colors.black,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryGradientStart,
                            AppColors.primary100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          // Tap action for starting workout
                        },
                      ),
                      const SizedBox(width: 16),
                      QuickActionCard(
                        icon: Icons.auto_awesome_rounded,
                        iconColor: AppColors.primary100,
                        tag: "ASK",
                        tagColor: AppColors.neutral60,
                        title: "Coach Albert",
                        titleColor: AppColors.neutral100,
                        onTap: () {
                          // Tap action for chatbot
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  // Routines Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your routines").subtitle1(color: AppColors.neutral100),
                      GestureDetector(
                        onTap: () {
                          // Tap action for seeing all routines
                        },
                        child: Text("See all").captionBold(color: AppColors.primary100),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Horizontally scrollable list of routines
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.routines.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final routine = controller.routines[index];
                        return RoutineCard(
                          name: routine.name,
                          exercisesCount: routine.exercisesCount,
                          icon: routine.icon,
                          onTap: () {
                            // Tap action for selecting routine
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
