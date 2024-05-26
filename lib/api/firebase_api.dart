import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification}');
  }

  Future<void> initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
  }

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
        final accessToken = await _getAccessToken();
        await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/trabajosrapid-f63a2/messages:send'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
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
      'message': {
        'token': token,
        'notification': {
          'title': 'Nuevo mensaje de $senderName',
          'body': message,
        },
        'data': {
          'via': 'FlutterFire Cloud Messaging!!!',
        },
      },
    });
  }

  Future<String> _getAccessToken() async {
    const serviceAccountPath = 'assets/service_account_file.json';
    try {
      final serviceAccountJson =
          await rootBundle.loadString(serviceAccountPath);
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );
      final authClient = await clientViaServiceAccount(
        serviceAccountCredentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );
      return authClient.credentials.accessToken.data;
    } catch (e) {
      print('Error reading service account file: $e');
      rethrow;
    }
  }
}
