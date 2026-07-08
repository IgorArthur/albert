import 'package:albert/features/home/presentation/getx/home_controller.dart';
import 'package:albert/features/navigation_bar/presentation/widgets/getx/navigation_bar_controller.dart';
import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/progress/presentation/getx/progress_controller.dart';
import 'package:albert/features/workouts/workouts.dart';
import 'package:albert/features/workouts/presentation/getx/session_controller.dart';
import 'package:albert/features/profile/profile.dart';
import 'package:albert/features/home/home.dart';
import 'package:get/get.dart';

void registerGetxControllers() {
  Get.put(NavigationBarController());
  Get.put(WorkoutsController());
  Get.put(SessionController());
  Get.put(ProfileController(), permanent: true);
  Get.put(ProgressController(), permanent: true);
  Get.put(HomeController(), permanent: true);
}
