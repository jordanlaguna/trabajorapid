import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotification() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('icono_app');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidNotificationAction =
      AndroidNotificationDetails(
    'Rapid',
    'RapidJobs',
  );
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationAction,
  );
  await flutterLocalNotificationsPlugin.show(
    1,
    'RapidJobs',
    '¡Tienes un nuevo mensaje!',
    notificationDetails,
  );
}
