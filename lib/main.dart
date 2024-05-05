import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trabajorapid/api/firebase_api.dart';
import 'package:trabajorapid/data/repositiories/auth_repository.dart';
import 'package:trabajorapid/firebase_options.dart';
import 'package:trabajorapid/app.dart';

void main() async {
  // -- WidgetsBinding Initialization
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // -- GetX Local Storage --
  await GetStorage.init();

  // -- await for the splash screen --
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Firebase Inicialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((FirebaseApp value) => Get.put(AuthRepository()));

  // Firebase Cloud Messaging
  FirebaseApi firebaseApi = FirebaseApi();

  // Firebase Notifications
  await firebaseApi.initNotifications();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(const MyApp());
}
