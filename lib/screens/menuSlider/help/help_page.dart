import 'package:flutter/material.dart';

class PageHelp extends StatelessWidget {
  const PageHelp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RapidJobs',
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Padding(
            padding: EdgeInsets.only(bottom: 0.0),
            child: Text(
              'Versión 1.0.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Center(
                child: Text(
                  'Ayuda y Soporte',
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
                    child: Image(
                      image: AssetImage('assets/logos/appLogo.png'),
                      height: 280,
                      width: 280,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            SizedBox(height: size.height * 0.02),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: const Text(
                  'Centro de Ayuda',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
            ),
            const Divider(),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: const Text(
                  'Condiciones y Políticas',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
            ),
            const Divider(),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: const Text(
                  'Guía',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                '© 2024 RapidJobs. Todos los derechos reservados.',
                style: TextStyle(
                  fontSize: 14,
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
}
