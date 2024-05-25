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
import 'package:trabajorapid/services/firebase_services/my_firebase_services.dart';
import 'package:trabajorapid/services/notification/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Inicializar MyFirebaseMessagingService
  MyFirebaseMessagingService().init();

  // Firebase Cloud Messaging
  FirebaseApi firebaseApi = FirebaseApi();

  // Firebase Notifications
  await firebaseApi.initNotifications();

  // Firebase Local Notifications
  await initNotification();

  // Update FCM Token
  await updateFCMToken();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(const MyApp());
}

// Function to update FCM Token
Future<void> updateFCMToken() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': fcmToken,
      });
      print(
          'FCM Token actualizado con éxito'); // FCM Token updated successfully
    }
  }
}
