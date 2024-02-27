import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trabajorapid/firebase_options.dart';
import 'package:trabajorapid/components/welcomeLogin/welcomePage.dart';

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
      title: 'TrabajoRapi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: ('Montserrat'),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}
