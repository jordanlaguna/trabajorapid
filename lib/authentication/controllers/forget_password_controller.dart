import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/authentication/screens/password_reset/reset_password.dart';
import 'package:trabajorapid/data/repositiories/auth_repository.dart';
import 'package:trabajorapid/utils/constans/image_strings.dart';
import 'package:trabajorapid/utils/constans/loaders.dart';
import 'package:trabajorapid/utils/network/network_manager.dart';
import 'package:trabajorapid/utils/popups/full_screen_loader.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  // Variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordformKey = GlobalKey<FormState>();

  //Send email to reset password
  sendPasswordResetEmail() async {
    try {
      // Iniciar el loader
      TFullScreenLoader.openLoadingDialog('Procesando tu solicitud...', TImages.docerLoading);

      // Verificar la conexion a internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validar el form
      if (!forgetPasswordformKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      await AuthRepository.instance.sendPasswordResetEmail(email.text.trim());

      // Cerrar el loader
      TFullScreenLoader.stopLoading();

      // Notificar al usuario
      TLoaders.successSnackBar(
          title: 'Correo enviado',
          message:'Revisa tu bandeja de entrada para restablecer tu contraseña'.tr);

      // Redireccionar al usuario
      Get.to(() => ResetPasswordScreen(email: email.text.trim()));

    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
          title: 'Ha ocurrido un error',
          message: e.toString());
    }
  }

  resendPasswordResetEmail(String email) async {
    try {
      // Iniciar el loader
      TFullScreenLoader.openLoadingDialog('Procesando tu solicitud...', TImages.docerLoading);

      // Verificar la conexion a internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Enviar el correo de restablecimiento de contraseña
      await AuthRepository.instance.sendPasswordResetEmail(email);

      // Cerrar el loader
      TFullScreenLoader.stopLoading();

      // Notificar al usuario
      TLoaders.successSnackBar(
          title: 'Correo enviado',
          message:'Revisa tu bandeja de entrada para restablecer tu contraseña'.tr);

    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
          title: 'Ha ocurrido un error',
          message: e.toString());
    }
  }
}
