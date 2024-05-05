import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trabajorapid/authentication/screens/login/login.dart';
import 'package:trabajorapid/authentication/screens/onboarding/onboarding.dart';
import 'package:trabajorapid/authentication/screens/signup/widgets/verify_email.dart';
import 'package:trabajorapid/data/repositiories/exceptions/firebase_auth_exceptions.dart';
import 'package:trabajorapid/screens/home/moduleMain.dart';
import 'exceptions/firebase_exceptions.dart';
import 'exceptions/format_exceptions.dart';
import 'exceptions/platform_exceptions.dart';

class AuthRepository extends GetxController {
  static AuthRepository get instance => Get.find();

  // Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  // Lamar al main.dart en app
  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  // Funciones
  screenRedirect() async {
    final user = _auth.currentUser;
    // si el usuario esta logeado
    if (user != null) {
      // si el usuario ha verificado su correo
      if (user.emailVerified) {
        // redireccionar al usuario a la pantalla principal
        Get.offAll(() => const ModuleMain());
      } else {
        // sino redireccionar al usuario a la pantalla de verificacion de correo
        Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
      }
    } else {
      // Using Local Storage
      deviceStorage.writeIfNull('IsFirstTime', true);
      deviceStorage.read('IsFirstTime') != true
          ? Get.offAll(() => const LoginScreen())
          : Get.offAll(const OnBoardingScreen());
    }
  }

   // ******* Firebase Functions *******
  // Login de usuarios - EmailAuth
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code);
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }

  // Registro de usuarios - EmailAuth
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code);
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }

  // Verificacion del correo de usuario - Email Verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code);
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }

  // GoogleAuth - Iniciar sesion con Google
    Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      // Obtener credenciales de Google
      final GoogleSignInAuthentication? googleAuth = await userAccount?.authentication;
      // Crear credenciales de Google
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Inicio de sesion una vez que se obtienen las credenciales y retornar las credenciales
      return await _auth.signInWithCredential(credentials);
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code);
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      if(kDebugMode) print('Ocurrio un error inesperado: $e');
      return null;
    }
  }

  // Cerrar sesion = LogoutUser
  Future<void> logoutUser() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(()=>const LoginScreen());
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code);
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }

}
