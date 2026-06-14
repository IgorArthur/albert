import 'package:get/get.dart';

class NavigationBarController extends GetxController {
  static NavigationBarController get to => Get.find();

  NavigationBarController() {
    _navigationBarIndex.value = 0;
  }

  final _navigationBarIndex = 0.obs;
  int get navigationBarIndex => _navigationBarIndex.value;

  void setCurrentRoute(int index) {
    _navigationBarIndex.value = index;
    update();
  }
}
