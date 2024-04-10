import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trabajorapid/components/menuSlider/perfilDrawer/profile_drawer.dart';
import 'package:trabajorapid/firebase_options.dart';
import 'package:trabajorapid/screens/welcome_screen.dart';
import 'package:trabajorapid/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/profile': (context) => const ProfileDrawer(),
      },
      title: 'RapidJobs',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: const WelcomeScreen(),
    );
  }
}
