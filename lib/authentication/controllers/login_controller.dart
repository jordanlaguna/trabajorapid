import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trabajorapid/authentication/controllers/user_controller.dart';
import 'package:trabajorapid/data/repositiories/auth_repository.dart';
import 'package:trabajorapid/main.dart';
import 'package:trabajorapid/utils/constans/image_strings.dart';
import 'package:trabajorapid/utils/constans/loaders.dart';
import 'package:trabajorapid/utils/network/network_manager.dart';
import 'package:trabajorapid/utils/popups/full_screen_loader.dart';

class LoginController extends GetxController {
  // Variables
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    final rememberMeEmail = localStorage.read('REMEMBER_ME_EMAIL');
    final rememberMePassword = localStorage.read('REMEMBER_ME_PASSWORD');

    if (rememberMeEmail != null) {
      email.text = rememberMeEmail;
    }

    if (rememberMePassword != null) {
      password.text = rememberMePassword;
    }

    super.onInit();
  }

  // Inicio de sesion con FirebaseAuth - Correo y Contraseña
  void emailAndPasswordSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Iniciando Sesión...', TImages.docerLoading);

      // Validar la conexion a internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validar el formulario
      if (!formKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Guardar data si el usuario selecciona recordar
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }

      // Iniciar sesion con Firebase
      await AuthRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // update FCM Token
      await updateFCMToken();

      // Detener el loader
      TFullScreenLoader.stopLoading();

      // Redireccionar al usuario
      AuthRepository.instance.screenRedirect();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
          title: 'Error al iniciar sesión', message: e.toString());
    }
  }

  // Google Sign In
  Future<void> googleSignIn() async {
    try {
      // Iniciar el loader
      TFullScreenLoader.openLoadingDialog(
          'Iniciando Sesión...', TImages.docerLoading);

      // Validar la conexion a internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      // Google Auth
      UserCredential? userCredentials =
          await AuthRepository.instance.signInWithGoogle();

      // Guardar el usuario
      //await userController.saveUserRecord(userCredentials);
      if (userCredentials != null) {
        await _saveUserToFirestore(userCredentials);
        // update FCM Token
        await updateFCMToken();

        // Detener el loader
        TFullScreenLoader.stopLoading();

        // Redireccionar al usuario
        AuthRepository.instance.screenRedirect();

        await updateUserActive(userCredentials.user!.uid, true);
      } else {
        print('Error al iniciar sesión con Google');
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
          title: 'Error al iniciar sesión', message: e.toString());
    }
  }

  // Method to add data to the user
  Future<void> _saveUserToFirestore(UserCredential userCredential) async {
    final User? user = userCredential.user;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final doc = await userRef.get();
      if (!doc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'photoURL': user.photoURL,
        });
      }
    }
  }

  // Method to update status of user
  Future<void> updateUserActive(String uid, bool isActive) async {
    final userRef = _firestore.collection('users').doc(uid);
    await userRef.update({'isActive': isActive});
  }
}
