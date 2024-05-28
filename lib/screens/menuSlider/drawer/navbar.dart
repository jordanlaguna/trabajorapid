// ignore_for_file: avoid_print, unused_element
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/data/repositiories/auth_repository.dart';
import 'package:trabajorapid/screens/menuSlider/configuration/configPage/page_config.dart';
import 'package:trabajorapid/screens/menuSlider/help/help_page.dart';
import 'package:trabajorapid/screens/menuSlider/page_chat/page_home_chat.dart';
import 'package:trabajorapid/screens/menuSlider/payment/payment_page.dart';
import 'package:trabajorapid/screens/menuSlider/profile_drawer/profile_drawer.dart';
import 'package:trabajorapid/screens/menuSlider/works/works_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

Future<String?> getUserPhotoUrl(String uid) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userData.exists) {
      return userData.data()?['photoURL'] as String?;
    }
    return null; // Return null if user data doesn't exist or photoURL is null.
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
                  return Container(
                    alignment: Alignment.center,
                    child: const DrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 65, 111, 223),
                            Color.fromARGB(255, 110, 174, 231),
                          ],
                        ),
                      ),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
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
                            } else {
                              // Verifica si la photoURL es vacía ("")
                              if (photoSnapshot.hasData &&
                                  photoSnapshot.data!.isNotEmpty) {
                                return Image.network(
                                  photoSnapshot.data!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                );
                              } else {
                                return const Icon(Icons.account_circle,
                                    size: 30);
                              }
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
            buildListTile(
                Icons.account_circle, 'Perfil', const ProfileDrawer()),
            buildListTile(Icons.message_rounded, 'Mensajes', const PageChat()),
            buildListTile(
                Icons.attach_money_rounded, 'Pagos', const PaymentPage()),
            buildListTile(
                Icons.work_history_rounded, 'Trabajos', const WorksPage()),
            const Divider(
              height: 30,
              color: Color.fromARGB(255, 65, 111, 223),
            ),
            buildListTile(Icons.help_rounded, 'Ayuda', const PageHelp()),
            buildListTile(
                Icons.settings_rounded, 'Configuración', const ConfigPage()),
            buildListTile(Icons.logout_rounded, 'Salir', null, onTap: () {
              AuthRepository.instance.logoutUser();
            }),
          ],
        ),
      ),
    );
  }

  ListTile buildListTile(IconData icon, String title, Widget? page,
      {Function()? onTap}) {
    return ListTile(
      leading: getIconWithShader(icon),
      title: buildTextStyle(title),
      onTap: onTap ??
          () {
            if (page != null) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => page));
            }
          },
    );
  }

  Text buildTextStyle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          color: Colors.black),
    );
  }

  ShaderMask getIconWithShader(IconData icon) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [
            Color.fromARGB(255, 65, 111, 223),
            Color.fromARGB(255, 110, 174, 231),
          ],
        ).createShader(bounds);
      },
      child: Icon(icon, size: 30, color: Colors.white),
    );
  }
}
