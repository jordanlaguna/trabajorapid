// ignore: file_names
import 'package:flutter/material.dart';
import 'package:trabajorapid/regPage.dart';
import 'loginPage.dart';

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
                'TrabajoRapi!',
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
              padding: const EdgeInsets.all(
                  8.0), // Relleno alrededor de todos los botones
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      // Acción cuando se presiona el botón de Facebook
                    },
                    icon: Image.asset('assets/images/facebook.png', height: 50),
                  ),
                  IconButton(
                    onPressed: () {
                      // Acción cuando se presiona el botón de Gmail
                    },
                    icon: Image.asset('assets/images/gmail.png', height: 50),
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
}
