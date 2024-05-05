import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/authentication/models/user_model.dart';
import 'package:trabajorapid/authentication/screens/signup/widgets/verify_email.dart';
import 'package:trabajorapid/data/repositiories/auth_repository.dart';
import 'package:trabajorapid/data/repositiories/user/user_repository.dart';
import 'package:trabajorapid/utils/constans/image_strings.dart';
import 'package:trabajorapid/utils/constans/loaders.dart';
import 'package:trabajorapid/utils/network/network_manager.dart';
import 'package:trabajorapid/utils/popups/full_screen_loader.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // Variables
  final hidePassword = true.obs;
  final privacyPolicy = true.obs;
  final fullname = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> signupformKey = GlobalKey<FormState>();

  // Registro de usuarios
  void signup() async {
    try {
      // Iniciar el loader
      TFullScreenLoader.openLoadingDialog(
          'Estamos procesando tu información...', TImages.docerLoading);

      // Comprobar la conexion a internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validar el formulario
      if (!signupformKey.currentState!.validate()) {
        //TFullScreenLoader.stopLoading(); si se descomenta esta linea, el loader no se detiene y por alguna razon me manda al loginSreen
        return;
      }

      // Politica de privacidad
      if (!privacyPolicy.value) {
        TLoaders.warningSnackBar(
            title: 'Acepta la politica de privacidad',
            message:
                'Para crear tu cuenta debes aceptar la Politica de Privacidad & Terminos de Servicio.');
        return;
      }

      // Registrar en Firebase
      final userCredential = await AuthRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim());

      // Guardar la data del usuario en firestore
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        fullname: fullname.text.trim(),
        isActive: false,
        email: email.text.trim(),
        phone: phone.text.trim(),
        profilePicture: '',
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      // Loader
      TFullScreenLoader.stopLoading();

      // Mensaje de exito
      TLoaders.successSnackBar(
          title: 'Felicitaciones',
          message: 'Tu cuenta ha sido creada con exito!');

      // Mover a la pantalla para verificar el correo
      Future.delayed(Duration.zero, () {
        Get.to(() => VerifyEmailScreen(email: email.text.trim()));
      });
      
    } catch (e) {
      // Detener el loader
      TFullScreenLoader.stopLoading();

      TLoaders.errorSnackBar(
          title: 'Ha ocurrido un error!', message: e.toString());
    } finally {
      TFullScreenLoader.stopLoading();
    }
  }
}
