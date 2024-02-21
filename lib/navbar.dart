import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Jordan Laguna Rodríguez'),
            accountEmail: const Text('jordanlaguna10@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(child: Image.asset('assets/images/profile.jpg')),
            ),
            decoration: BoxDecoration(color: Colors.brown[600]),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Perfil'),
            onTap: () => print('Perfil presionado'),
          ),
          ListTile(
            leading: const Icon(Icons.message_rounded),
            title: const Text('Mensajes'),
            onTap: () => print('Mensajes presionado'),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded),
            title: const Text('Pagos'),
            onTap: () => print('Pagos presionado'),
          ),
          ListTile(
            leading: const Icon(Icons.work_history),
            title: const Text('Trabajos'),
            onTap: () => print('Trabajos presionado'),
          ),
          ListTile(
            leading: const Icon(Icons.help_rounded),
            title: const Text('Ayuda'),
            onTap: () => print('Ayuda presionado'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Configuración'),
            onTap: () => print('Configuracion presionado'),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Salir'),
            onTap: () => print('Salir presionado'),
          ),
        ],
      ),
    );
  }
}
