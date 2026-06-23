import 'package:albert/features/navigation_bar/presentation/widgets/getx/navigation_bar_controller.dart';
import 'package:albert/features/workouts/workouts.dart';
import 'package:albert/features/profile/profile.dart';
import 'package:albert/features/home/home.dart';
import 'package:get/get.dart';

void registerGetxControllers() {
  Get.put(NavigationBarController());
  Get.put(WorkoutsController());
  Get.put(ProfileController());
  Get.put(HomeController());
}
