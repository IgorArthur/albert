import 'package:albert/features/home/presentation/getx/home_controller.dart';
import 'package:albert/features/home/presentation/widgets/coach_albert_card.dart';
import 'package:albert/features/home/presentation/widgets/level_card.dart';
import 'package:albert/features/home/presentation/widgets/routine_card.dart';
import 'package:albert/features/home/presentation/widgets/start_workout_card.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:albert/features/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.to;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshAppData,
        color: AppColors.primary100,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(20.0, topPadding + 24.0, 20.0, 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text('home_welcome_back'.tr).overline(color: AppColors.primary100),
            const SizedBox(height: 6),
            Text('home_subtitle'.tr).display(),
            const SizedBox(height: 6),
            Text('home_body'.tr).body1(color: AppColors.neutral60),

            const SizedBox(height: 32),
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
              // Routines Section — reactive, hidden when empty
              Obx(() {
                final routines = controller.routines;

                if (routines.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('home_your_routines'.tr).subtitle1(color: AppColors.neutral100),
                        GestureDetector(
                          onTap: () => controller.seeAllRoutines(context),
                          child: Text('home_see_all'.tr).captionBold(color: AppColors.primary100),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: routines.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (_, index) => RoutineCard(routine: routines[index]),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
