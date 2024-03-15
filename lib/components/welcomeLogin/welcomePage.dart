// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:trabajorapid/components/register/regPage.dart';
import 'package:trabajorapid/components/login/loginPage.dart';
import 'package:trabajorapid/mainHome/moduleMain.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);
  @override
  State<WelcomePage> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    var sizeWindow = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xffB81736),
            Color(0xff281537),
          ]),
        ),
        child: Column(
          children: [
            const SizedBox(height: 70.0),
            const Text(
              'TrabajosRapid',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            const Image(
              image: AssetImage('assets/images/Logo.png'),
              height: 200,
              width: 200,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Bienvenido',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              child: Container(
                height: 53,
                width: sizeWindow * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white),
                ),
                child: const Center(
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const RegPage()));
              },
              child: Container(
                height: 53,
                width: sizeWindow * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white),
                ),
                child: const Center(
                  child: Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Iniciar con redes sociales',
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SocialLoginButton(
              width: sizeWindow * 0.85,
              buttonType: SocialLoginButtonType.google,
              text: "Iniciar con Google",
              borderRadius: 80.0,
              fontSize: 17.0,
              onPressed: () {
                _signInWithGoogle();
              },
            ),
            const SizedBox(height: 10),
            SocialLoginButton(
              width: sizeWindow * 0.85,
              buttonType: SocialLoginButtonType.facebook,
              text: "Iniciar con Facebook",
              borderRadius: 80.0,
              fontSize: 17.0,
              onPressed: () {
                signInWithFacebook();
              },
            ),
            const SizedBox(height: 10),
            SocialLoginButton(
              width: sizeWindow * 0.85,
              buttonType: SocialLoginButtonType.microsoft,
              text: "Iniciar con Microsoft",
              borderRadius: 80.0,
              fontSize: 17.0,
              onPressed: () {
                _signInWithMicrosoft();
              },
            ),
          ],
        ),
      ),
    );
  }

  _signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
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
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Inicio de sesión exitoso!',
          autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: false,
        );
        await Future.delayed(const Duration(seconds: 3));

        await _firebaseAuth.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ModuleMain()),
        );
      }
    } catch (e) {
      print("some error occured $e");
    }
  }

  signInWithFacebook() async {
    final FacebookLogin fb = FacebookLogin();
    try {
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

  _signInWithMicrosoft() async {
    // Implementación del inicio de sesión con Microsoft
  }
}
