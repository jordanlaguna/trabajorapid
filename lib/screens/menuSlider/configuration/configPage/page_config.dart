import 'package:flutter/material.dart';
import 'package:trabajorapid/screens/menuSlider/configuration/aboutOfPage/page_about.dart';
import 'package:trabajorapid/screens/menuSlider/configuration/PolicyPage/page_policy.dart';
import 'package:trabajorapid/screens/menuSlider/configuration/frequentQuest/frequent_quest.dart';
import 'package:trabajorapid/screens/menuSlider/configuration/legalPage/page_legal.dart';
import 'package:trabajorapid/screens/menuSlider/configuration/securityPage/security_page.dart';
import 'package:trabajorapid/screens/menuSlider/profile_drawer/profile_drawer.dart';

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
          _buildListItem(
            title: 'Información de perfil',
            icon: Icons.person,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ProfileDrawer();
              }));
            },
          ),
          _buildDivider(),
          _buildListItem(
            title: 'Preguntas frecuentes',
            icon: Icons.help,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PageQuest()),
              );
            },
          ),
          _buildDivider(),
          _buildListItem(
            title: 'Seguridad',
            icon: Icons.security,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PageSecurity()),
              );
            },
          ),
          _buildDivider(),
          _buildListItem(
            title: 'Privacidad',
            icon: Icons.privacy_tip,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PagePolicy()),
              );
            },
          ),
          _buildDivider(),
          _buildListItem(
            title: 'Legal',
            icon: Icons.gavel,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PageLegal()),
              );
            },
          ),
          _buildDivider(),
          _buildListItem(
            title: 'Acerca de Rapid Jobs',
            icon: Icons.info,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PageAbout()),
              );
            },
          ),
          _buildDivider(),
          _buildListItem(
            title: 'Desactivar cuenta',
            icon: Icons.cancel,
            onTap: () {},
          ),
        ],
      ),
      backgroundColor: Colors.blue[50],
    );
  }

  Widget _buildListItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 60,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: Icon(
          icon,
          color: Colors.blue,
          size: 30,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white,
      thickness: 2.0,
    );
  }
}
