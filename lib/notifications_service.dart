import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// إنشاء المتغير العام للمكتبة
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// تهيئة الإشعارات المحلية
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (kDebugMode) {
      }
    },
  );
}

// عرض الإشعار
Future<void> showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel', // معرف القناة
    'Default Channel', // اسم القناة
    channelDescription: 'FCM Notifications', // وصف القناة
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
  message.hashCode, // id
  message.notification?.title ?? 'Notification', // title
  message.notification?.body ?? 'No body',       // body
  notificationDetails,                           // NotificationDetails
  payload: message.data.toString(),              // بيانات إضافية
);
}

