import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trabajorapid/mainHome/moduleMain.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class SocialAuth {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const ModuleMain()),
        );
      }
    } catch (e) {
      print("Error al registrar con Google: $e");
    }
  }

  static Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final FacebookLogin fb = FacebookLogin();
      final FacebookLoginResult result = await fb.logIn(permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ]);

      switch (result.status) {
        case FacebookLoginStatus.success:
          final FacebookAccessToken accessToken = result.accessToken!;
          print('Access token: ${accessToken.token}');

          final AuthCredential credential = FacebookAuthProvider.credential(
            accessToken.token,
          );

          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);

          // Verifica si la autenticación con Firebase fue exitosa
          if (userCredential.user != null) {
            // Navega a ModuleMain() después del inicio de sesión exitoso
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const ModuleMain()),
            );
          }
          break;
        case FacebookLoginStatus.cancel:
          print(
              'El inicio de sesión con Facebook fue cancelado por el usuario');
          break;
        case FacebookLoginStatus.error:
          print('Error al iniciar sesión con Facebook: ${result.error}');
          break;
      }
    } catch (e) {
      print('Error al iniciar sesión con Facebook: $e');
    }
  }
}
