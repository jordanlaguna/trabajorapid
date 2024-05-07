// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _firebaseFirestore = FirebaseFirestore.instance;

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
  // fuction for the update isActive to user in firebase
  Future<void> updateUserActive(String uid, bool isActive) async {
    try {
      await _firebaseFirestore.collection('users').doc(uid).update({
        'isActive': isActive,
      });
      print('Usuario actualizado con éxito');
    } catch (error) {
      print('Error al actualizar el usuario: $error');
    }
  }

  // Login de usuarios - EmailAuth
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;
      await updateUserActive(uid, true);
      print('Usuario activo!');
      return userCredential;
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code).message;
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }

  // Registro de usuarios - EmailAuth
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code).message;
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }

  // Verificacion del correo de usuario - Email Verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code).message;
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }

// GoogleAuth - Iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Iniciar el flujo de autenticación
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      // Obtener credenciales de Google
      final GoogleSignInAuthentication? googleAuth =
          await userAccount?.authentication;
      // Crear credenciales de Google
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Iniciar sesión una vez que se obtienen las credenciales y retornar las credenciales
      final userCredential = await _auth.signInWithCredential(credentials);

      // Verificar si el inicio de sesión fue exitoso
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        await updateUserActive(uid, true);
        print('Usuario activo');
        print('Usuario activo!');
      }

      return userCredential;
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code).message;
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Ocurrió un error inesperado: $e');
      return null;
    }
  }

  // Olvidar contraseña - ForgotPassword
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code).message;
      // ignore: dead_code_on_catch_subtype
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }

  // Cerrar sesion = LogoutUser
  Future<void> logoutUser() async {
    try {
      // Cerrar sesión en Google (si está conectado)
      await GoogleSignIn().signOut();

      String? uid = FirebaseAuth.instance.currentUser?.uid;
      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();
      if (uid != null) {
        // Actualizar el estado del usuario a false
        await updateUserActive(uid, false);
        print('Usuario inactivo!');
      } else {
        print('No se pudo obtener el UID del usuario antes de cerrar sesión');
      }

      // Navegar a la pantalla de inicio de sesión
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } catch (e) {
      throw 'Se ha producido un error inesperado';
    }
  }
}
