import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/utils/constans/colors.dart';
import 'package:trabajorapid/utils/helpers/helpers_functions.dart';
import 'package:trabajorapid/utils/loaders/animation_loader.dart';

class TFullScreenLoader{
  static void openLoadingDialog(String text, String animation){
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          color: THelperFunctions.isDarkMode(Get.context!) ? TColors.dark : TColors.white,
          width: double.infinity,
          height: double.infinity,
          child: TAnimationLoaderWidget(text: text, animation: animation),
        ),
      ),
    );
  }

  static stopLoading(){
    Navigator.of(Get.overlayContext!).pop(); // Cerrar el diálogo
  }
}
