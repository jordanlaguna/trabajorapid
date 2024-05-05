import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trabajorapid/authentication/screens/login/login.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  // Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // actualiza el indicador de la página
  void updatePageIndicator(index) => currentPageIndex.value = index;

  // Navegación de puntos
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  // Navegar a la siguiente página
  void nextPage() {
    if (currentPageIndex.value == 2) {
      final storage = GetStorage();
      storage.write('IsFirstTime', false);
      Get.offAll(const LoginScreen());
    }else{
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  // Saltar todo el proceso de Onboarding
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpTo(2);
    Get.offAll(const LoginScreen());
  }
}
