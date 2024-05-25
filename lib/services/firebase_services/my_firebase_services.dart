import 'package:firebase_messaging/firebase_messaging.dart';

class MyFirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification}');
  }
}
