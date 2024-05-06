import 'package:flutter/material.dart';

class PageSecurity extends StatelessWidget {
  const PageSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seguridad',
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Center(
                child: Text(
                  'Políticas de Seguridad',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              subtitle: Column(
                children: [
                  SizedBox(height: size.height * 0.03),
                  const Center(
                    child: Icon(
                      Icons.security,
                      size: 90,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                'Tus chats y servicios son seguros',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                'El cifrado de RapidJobs permite que tus mensajes, servicios y datos personales estén protegidos y seguros.\nEstos datos no son compartidos con terceros, al menos que tú lo decidas. Este cifrado se aplica en todos los servicios de RapidJobs:',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLinkColumn(Icons.business, 'Servicios', context),
                _buildLinkColumn(Icons.chat, 'Chats', context),
                _buildLinkColumn(Icons.photo, 'Fotos', context),
                _buildLinkColumn(Icons.location_on, 'Ubicación', context),
              ],
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Más información',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkColumn(IconData icon, String text, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
