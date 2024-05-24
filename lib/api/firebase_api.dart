import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseApi {
  // create an instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  final String _serverKey = 'AIzaSyCRtbvKx1iBuh6lKmLLxHerpP_iU1mvg74';

  // function to initialize notifications
  Future<void> initNotifications() async {
    // request for permission
    await _firebaseMessaging.requestPermission();

    // fetch the token from the firebase messaging
    final fCMToken = await _firebaseMessaging.getToken();

    // print the token
    print('FCM Token: $fCMToken');
  }

  // function to handle received messages
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
  Future initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessage.listen(handleMessage);
  }

  // function to send push notifications
  Future<void> sendPushNotification(
      String receiverId, String senderName, String message) async {
    final tokenSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();
    final token = tokenSnapshot.data()?['fcmToken'];

    if (token != null) {
      final payload = constructFCMPayload(token, senderName, message);

      try {
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'key=$_serverKey',
          },
          body: payload,
        );
        print('FCM request for device sent!');
      } catch (e) {
        print('Error sending FCM message: $e');
      }
    }
  }

  String constructFCMPayload(String token, String senderName, String message) {
    return jsonEncode({
      'to': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
      },
      'notification': {
        'title': 'Nuevo mensaje de $senderName',
        'body': message,
      },
    });
  }
}
