import 'package:flutter/material.dart';

class PageAbout extends StatelessWidget {
  const PageAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acerca de',
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 35, left: 75, right: 0),
        child: const Column(
          children: [
            SizedBox(height: 170.0),
            Image(
              image: AssetImage('assets/images/Logo.png'),
              height: 150,
              width: 150,
              alignment: Alignment.center,
            ),
            SizedBox(height: 10),
            Text(
              'Rapid Jobs versión 1.0.0',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
