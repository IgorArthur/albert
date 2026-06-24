import 'package:albert/features/home/presentation/getx/home_controller.dart';
import 'package:albert/features/home/presentation/widgets/coach_albert_card.dart';
import 'package:albert/features/home/presentation/widgets/level_card.dart';
import 'package:albert/features/home/presentation/widgets/routine_card.dart';
import 'package:albert/features/home/presentation/widgets/start_workout_card.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.to;

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
              // Welcome Header
              Text("WELCOME BACK").overline(color: AppColors.primary100),
              const SizedBox(height: 4),
              Text("Let's lift, athlete.").display(color: AppColors.neutral100),
              const SizedBox(height: 4),
              Text("Albert is ready to coach your next set.").body1(color: AppColors.neutral60),

              const SizedBox(height: 28),
              // Athlete Level Card
              const LevelCard(),

              const SizedBox(height: 24),
              // Quick Actions
              const Row(
                children: [
                  StartWorkoutCard(),
                  SizedBox(width: 16),
                  CoachAlbertCard(),
                ],
              ),

              const SizedBox(height: 32),
              // Routines Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Your routines").subtitle1(color: AppColors.neutral100),
                  GestureDetector(
                    onTap: controller.seeAllRoutines,
                    child: Text("See all").captionBold(color: AppColors.primary100),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Horizontally scrollable routines
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.routines.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, index) => RoutineCard(routine: controller.routines[index]),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
