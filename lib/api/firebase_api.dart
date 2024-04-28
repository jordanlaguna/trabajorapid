// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  // create an instace of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  // function to initalize notifications
  Future<void> initNotifications() async {
    // request for permission
    await _firebaseMessaging.requestPermission();

    // fetch the token from the firebase messaging
    final fCMToken = await _firebaseMessaging.getToken();

    // print the token
    print('FCM Token: $fCMToken');
  }

  // function to handle recived messages
  void handleMessage(RemoteMessage? message) {
    // check if the message is null
    if (message == null) {
      return;
    }
    // print the message data
    print('Message data: ${message.data}');
    // print the message notification
    print('Message notification: ${message.notification}');
  }

  // function to initialize foreground and background settings
  Future iniPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then((handleMessage));

    FirebaseMessaging.onMessage.listen((handleMessage));
  }
}
