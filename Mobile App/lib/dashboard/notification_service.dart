import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showFireAlertNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
  'fire_alert_channel',
  'Fire Alerts',
  channelDescription: 'Notifications for fire detection alerts',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
  sound: RawResourceAndroidNotificationSound('alert'),
  enableVibration: true,
  vibrationPattern: Int64List.fromList([0, 500, 1000, 500].map((e) => e.toInt()).toList()),
  playSound: true,
  enableLights: true,
  ledColor: const Color.fromARGB(255, 255, 0, 0),
  ledOnMs: 1000,
  ledOffMs: 500,
);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(
      0, // notification id
      'Fire Detected!', // title
      'Flame detected in your pet area! Please check immediately!', // body
      notificationDetails,
    );
  }
}