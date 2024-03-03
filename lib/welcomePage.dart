// ignore_for_file: file_names, avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
<<<<<<< HEAD:lib/welcomePage.dart
import 'package:trabajorapid/regPage.dart';
import 'loginPage.dart';
import 'package:trabajorapid/moduleMain.dart';
=======
import 'package:trabajorapid/components/register/regPage.dart';
import 'package:trabajorapid/components/login/loginPage.dart';
import 'package:trabajorapid/mainHome/moduleMain.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

>>>>>>> 2bb41e6 (facebook-login):lib/components/welcomeLogin/welcomePage.dart

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            const Padding(
              padding: EdgeInsets.only(top: 70.0),
              child: Text(
                'TrabajosRapid!',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 90.0),
              child: Image(
                image: AssetImage('assets/images/Logo.png'),
                height: 200,
                width: 200,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Bienvenido!',
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              child: Container(
                height: 53,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white),
                ),
                child: const Center(
                  child: Text('Iniciar Sesión',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const RegPage()));
              },
              child: Container(
                height: 53,
                width: 320,
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
                        color: Colors.black),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Iniciar con redes sociales',
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      signInWithFacebook();
                    },
                    icon: Image.asset('assets/images/facebook.png', height: 50),
                  ),
                  GestureDetector(
                    onTap: () {
                      _signInWithGoogle(context);
                    },
                    child: IconButton(
                      onPressed: () {
                        _signInWithGoogle(context);
                      },
                      icon: Image.asset('assets/images/gmail.png', height: 50),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Acción cuando se presiona el botón de Instagram
                    },
                    icon:
                        Image.asset('assets/images/instagram.png', height: 50),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ModuleMain()),
          );
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
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
          print('El inicio de sesión con Facebook fue cancelado por el usuario');
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
