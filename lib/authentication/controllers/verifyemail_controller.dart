import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/common/widgets/success_screen.dart';
import 'package:trabajorapid/data/repositiories/auth_repository.dart';
import 'package:trabajorapid/utils/constans/image_strings.dart';
import 'package:trabajorapid/utils/constans/loaders.dart';
import 'package:trabajorapid/utils/constans/text_strings.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  @override
  void onInit() {
    sendEmailVerification();
    setTimeForAutoRedirect();
    super.onInit();
  }

  // Enviar el link de verificacion por correo
  sendEmailVerification() async {
    try {
      await AuthRepository.instance.sendEmailVerification();
      TLoaders.successSnackBar(
          title: 'Correo de verificación enviado!',
          message: 'Por favor revisa tu bandeja de entrada');
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Ha ocurrido un error!', message: e.toString());
    }
  }

  // Redireccionar al usuario despues
  setTimeForAutoRedirect() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await FirebaseAuth.instance.currentUser!.reload();
      final user = FirebaseAuth.instance.currentUser;
      if(user?.emailVerified ?? false){
        timer.cancel();
        Get.off(
          ()=>SuccessScreen(
          image: TImages.successRegister,
          title: TText.yourAccountCreatedTitle,
          subTitle: TText.yourAccountCreatedSubtitle,
          onPressed: () => AuthRepository.instance.screenRedirect(),
          ));
      }
    });
  }

  // Verificar si el correo ha sido verificado
  checkEmailVerificationStatus()async{
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null && currentUser.emailVerified){
      Get.off(
          ()=>SuccessScreen(
          image: TImages.successRegister,
          title: TText.yourAccountCreatedTitle,
          subTitle: TText.yourAccountCreatedSubtitle,
          onPressed: () => AuthRepository.instance.screenRedirect(),
          ));
    }
  }
}
