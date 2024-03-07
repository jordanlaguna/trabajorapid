// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/components/menuSlider/page_chat/page_home_chat.dart';
import 'package:trabajorapid/components/welcomeLogin/welcomePage.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
            accountEmail: Text(
              FirebaseAuth.instance.currentUser?.email ?? 'Correo electrónico',
              style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                  child: Image.network(
                      FirebaseAuth.instance.currentUser?.photoURL ??
                          'URL de la imagen')),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffB81736),
                  Color(0xff281537),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle,
              color: Colors.black,
              size: 30,
            ),
            title: const Text(
              'Perfil',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            onTap: () => print('Perfil presionado'),
          ),
          ListTile(
            leading: const Icon(Icons.message_rounded,
                color: Colors.black, size: 30),
            title: const Text(
              'Mensajes',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PageChat()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded,
                color: Colors.black, size: 30),
            title: const Text(
              'Pagos',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            onTap: () => print('Pagos presionado'),
          ),
          ListTile(
            leading:
                const Icon(Icons.work_history, color: Colors.black, size: 30),
            title: const Text(
              'Trabajos',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            onTap: () => print('Trabajos presionado'),
          ),
          ListTile(
            leading:
                const Icon(Icons.notifications, color: Colors.black, size: 30),
            title: const Text(
              'Notificaciones',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            onTap: () => print('Notificaciones presionado'),
          ),
          const Divider(
            height: 30,
            color: Colors.black,
          ),
          ListTile(
            leading:
                const Icon(Icons.help_rounded, color: Colors.black, size: 30),
            title: const Text(
              'Ayuda',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            onTap: () => print('Ayuda presionado'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded,
                color: Colors.black, size: 30),
            title: const Text(
              'Configuración',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            onTap: () => print('Configuracion presionado'),
          ),
          ListTile(
            leading:
                const Icon(Icons.logout_rounded, color: Colors.black, size: 30),
            title: const Text(
              'Salir',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()));
            },
          ),
        ],
      ),
    );
  }
}
