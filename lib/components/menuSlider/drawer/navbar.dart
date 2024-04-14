// ignore_for_file: avoid_print, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/components/menuSlider/configuration/configPage/page_config.dart';
import 'package:trabajorapid/components/menuSlider/page_chat/page_home_chat.dart';
import 'package:trabajorapid/components/menuSlider/perfilDrawer/profile_drawer.dart';
import 'package:trabajorapid/screens/welcome_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                FirebaseAuth.instance.currentUser?.displayName ??
                    'Nombre de usuario',
                style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ??
                    'Correo electrónico',
                style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.network(
                    _getUserPhotoURL() ??
                        '', // Si _getUserPhotoURL() devuelve null, se usa una cadena vacía
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.account_circle,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              title: const Text(
                'Perfil',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileDrawer()));
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.message_rounded,
                    size: 30, color: Colors.white),
              ),
              title: const Text(
                'Mensajes',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const PageChat()));
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.attach_money_rounded,
                    size: 30, color: Colors.white),
              ),
              title: const Text(
                'Pagos',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () => print('Pagos presionado'),
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.work_history,
                    size: 30, color: Colors.white),
              ),
              title: const Text(
                'Trabajos',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () => print('Trabajos presionado'),
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.notifications,
                    size: 30, color: Colors.white),
              ),
              title: const Text(
                'Notificaciones',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () => print('Notificaciones presionado'),
            ),
            const Divider(
              height: 30,
              color: Color(0xffB81736),
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.help_rounded,
                    size: 30, color: Colors.white),
              ),
              title: const Text(
                'Ayuda',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () => print('Ayuda presionado'),
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.settings_rounded,
                    size: 30, color: Colors.white),
              ),
              title: const Text(
                'Configuración',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConfigPage()));
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.logout_rounded,
                    size: 30, color: Colors.white),
              ),
              title: const Text(
                'Salir',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // me queda revisar esta funcion para facebook no carga la foto de perfil aun
  String? _getUserPhotoURL() {
    if (FirebaseAuth.instance.currentUser != null) {
      //  si el usuario ha iniciado sesion con google
      if (FirebaseAuth.instance.currentUser!.providerData
          .any((userInfo) => userInfo.providerId == 'google.com')) {
        // devuelve URL de la foto de perfil de Google
        return FirebaseAuth.instance.currentUser?.photoURL;
      }
      // si el usuario ha iniciado sesion con Facebook
      else if (FirebaseAuth.instance.currentUser!.providerData
          .any((userInfo) => userInfo.providerId == 'facebook.com')) {
        return 'https://graph.facebook.com/${FirebaseAuth.instance.currentUser?.uid}/picture?height=500';
      }
    }
    // si no hay usuario o no se ha iniciado session con Google ni Facebook, retorna null
    return null;
  }
}
