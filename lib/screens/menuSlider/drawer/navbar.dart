// ignore_for_file: avoid_print, unused_element
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/data/repositiories/auth_repository.dart';
import 'package:trabajorapid/screens/menuSlider/configuration/configPage/page_config.dart';
import 'package:trabajorapid/screens/menuSlider/help/help_page.dart';
import 'package:trabajorapid/screens/menuSlider/page_chat/page_home_chat.dart';
import 'package:trabajorapid/screens/menuSlider/payment/payment_page.dart';
import 'package:trabajorapid/screens/menuSlider/perfilDrawer/profile_drawer.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

Future<String?> getUserPhotoUrl(String uid) async {
  try {
    // Intenta obtener la URL de la foto del usuario desde la base de datos
    DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // Si la URL de la foto está disponible en la base de datos, úsala
    if (userData.exists && userData['photoURL'] != null) {
      return userData['photoURL'];
    } else {
      // Si la URL de la foto no está disponible en la base de datos, utiliza la foto de perfil de la autenticación
      return FirebaseAuth.instance.currentUser?.photoURL;
    }
  } catch (e) {
    print('Error obteniendo la URL de la foto del usuario: $e');
    return null;
  }
}

class _NavBarState extends State<NavBar> {
  final _firebaseFirestore = FirebaseFirestore.instance;
  String? get userUid => FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, dynamic>?> getUserData(String? uid) async {
    if (uid == null) return null;
    try {
      DocumentSnapshot<Map<String, dynamic>> userData =
          await _firebaseFirestore.collection('users').doc(uid).get();
      return userData.data();
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: getUserData(userUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 65, 111, 223),
                          Color.fromARGB(255, 110, 174, 231),
                        ],
                      ),
                    ),
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                } else if (snapshot.hasData) {
                  return UserAccountsDrawerHeader(
                    accountName: Text(
                      snapshot.data?['name'] ?? 'Nombre de usuario',
                      style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    accountEmail: Text(
                      snapshot.data?['email'] ?? 'Correo electrónico',
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: FutureBuilder<String?>(
                          future: getUserPhotoUrl(userUid!),
                          builder: (context, photoSnapshot) {
                            if (photoSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (photoSnapshot.hasError) {
                              return const Icon(Icons.error_outline,
                                  size: 30, color: Colors.red);
                            } else if (photoSnapshot.hasData) {
                              return Image.network(
                                photoSnapshot.data!,
                                fit: BoxFit.cover,
                              );
                            } else {
                              return const Icon(Icons.account_circle, size: 30);
                            }
                          },
                        ),
                      ),
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 65, 111, 223),
                          Color.fromARGB(255, 110, 174, 231),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 65, 111, 223),
                          Color.fromARGB(255, 110, 174, 231),
                        ],
                      ),
                    ),
                    child: Text("No se pudo cargar la información del usuario"),
                  );
                }
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 65, 111, 223),
                      Color.fromARGB(255, 110, 174, 231),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileDrawer()));
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 65, 111, 223),
                      Color.fromARGB(255, 110, 174, 231),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const PageChat()));
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 65, 111, 223),
                      Color.fromARGB(255, 110, 174, 231),
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
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentPage()));
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 65, 111, 223),
                      Color.fromARGB(255, 110, 174, 231),
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
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 65, 111, 223),
                      Color.fromARGB(255, 110, 174, 231),
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
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 65, 111, 223),
                      Color.fromARGB(255, 110, 174, 231),
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
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const PageHelp()));
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 65, 111, 223),
                      Color.fromARGB(255, 110, 174, 231),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConfigPage()));
              },
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 65, 111, 223),
                      Color.fromARGB(255, 110, 174, 231),
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
                AuthRepository.instance.logoutUser();
              },
            ),
          ],
        ),
      ),
    );
  }
}
