// ignore: file_names
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:trabajorapid/screens/menuSlider/drawer/navbar.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/favorite_page/favorite.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/home_page/home.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/profile_page/profile.dart';
import 'package:trabajorapid/screens/bottom_navigationbar/work_page/works.dart';

void main() {
  runApp(const ModuleMain());
}

class ModuleMain extends StatefulWidget {
  const ModuleMain({Key? key}) : super(key: key);

  @override
  State<ModuleMain> createState() => _ModuleMainState();
}

class _ModuleMainState extends State<ModuleMain> {
  int index = 0;
  final List<Widget> screens = [
    const HomePage(),
    const ProfilePage(),
    const Favorite(),
    WorksPage(key: WorksPage.pageKey),
  ];

  List<Widget>? _getActionsForPage(int index) {
    if (index == 3) {
      // WorksPage
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => WorksPage.showJobSearch(context),
        ),
        PopupMenuButton<String>(
          onSelected: (String result) {
            WorksPage.pageKey.currentState?.filtrarTrabajos(result);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Todos',
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Todos'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Pendiente',
              child: Row(
                children: [
                  Icon(Icons.pending, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Pendiente'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'En Proceso',
              child: Row(
                children: [
                  Icon(Icons.work, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text('En Proceso'),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      const Icon(
        Icons.home,
        color: Colors.white,
        size: 35,
      ),
      const Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 35,
      ),
      const Icon(Icons.favorite, color: Colors.white, size: 35),
      const Icon(Icons.work_rounded, color: Colors.white, size: 35),
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blue[50],
        drawer: const NavBar(),
        appBar: AppBar(
          title: const Text(
            'Rapid Jobs',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              color: Colors.white,
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
          iconTheme: const IconThemeData(color: Colors.white, size: 35),
          actions: _getActionsForPage(index),
        ),
        body: screens.elementAt(index),
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color.fromARGB(255, 65, 111, 223),
          backgroundColor: Colors.transparent,
          items: items,
          height: 65,
          index: index,
          onTap: (newIndex) {
            setState(() {
              index = newIndex % screens.length;
            });
          },
        ),
      ),
    );
  }
}