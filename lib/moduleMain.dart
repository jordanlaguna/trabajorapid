// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:trabajorapid/navbar.dart';

void main() {
  runApp(const ModuleMain());
}

class ModuleMain extends StatefulWidget {
  const ModuleMain({Key? key}) : super(key: key);

  @override
  State<ModuleMain> createState() => _ModuleMainState();
}

class _ModuleMainState extends State<ModuleMain> {
  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color.fromARGB(255, 107, 50, 60);
    const Color headColor = Color.fromARGB(255, 121, 90, 90);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: const NavBar(),
        appBar: AppBar(
          title: const Text(
            'TrabajosRapid',
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                color: Colors.white),
          ),
          backgroundColor: headColor,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor,
                Color.fromARGB(255, 59, 48, 66),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
