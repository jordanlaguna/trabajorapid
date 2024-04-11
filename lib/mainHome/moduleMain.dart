// ignore_for_file: file_names
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:trabajorapid/components/menuSlider/drawer/navbar.dart';
import 'package:trabajorapid/pageMenuBottom/favorite_page/favorite.dart';
import 'package:trabajorapid/pageMenuBottom/home_page/home.dart';
import 'package:trabajorapid/pageMenuBottom/profile_page/profile.dart';
import 'package:trabajorapid/pageMenuBottom/work_page/works.dart';

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
  final screen = const [
    HomePage(),
    ProfilePage(),
    Favorite(),
    WorksPage(),
  ];

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
        backgroundColor: Colors.white,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white, size: 35),
        ),
        body: screen.elementAt(index),
        bottomNavigationBar: CurvedNavigationBar(
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.transparent,
          items: items,
          height: 65,
          index: index,
          onTap: (newIndex) {
            setState(() {
              index = newIndex % screen.length;
            });
          },
        ),
      ),
    );
  }
}
