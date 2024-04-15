import 'package:flutter/material.dart';
import 'package:trabajorapid/components/menuSlider/configuration/aboutOf/page_about.dart';
import 'package:trabajorapid/components/menuSlider/perfilDrawer/profile_drawer.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuraciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 65, 111, 223),
                Color.fromARGB(255, 110, 174, 231),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 35, left: 0, right: 0),
        children: [
          Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: const Text(
                'Información de perfil',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileDrawer()),
                );
              },
            ),
          ),
          const Divider(
            color: Colors.white,
            thickness: 2.0,
          ),
          Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: const Text(
                'Idioma',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileDrawer()),
                );
              },
            ),
          ),
          const Divider(
            color: Colors.white,
            thickness: 2.0,
          ),
          Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: const Text(
                'Seguridad',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileDrawer()),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: const Text(
                'Legal',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileDrawer()),
                );
              },
            ),
          ),
          const Divider(
            color: Colors.white,
            thickness: 2.0,
          ),
          Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: const Text(
                'Privacidad',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileDrawer()),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: const Text(
                'Acerca de Rapid Jobs',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PageAbout()),
                );
              },
            ),
          ),
          const Divider(
            color: Colors.white,
            thickness: 2.0,
          ),
          Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: const Text(
                'Desactivar cuenta',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileDrawer()),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue[50],
    );
  }
}
