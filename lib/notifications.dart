import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationSender {
  static final NotificationSender _instance = NotificationSender._();
  factory NotificationSender() => _instance;
  NotificationSender._();

  final plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher_round'),
      iOS: DarwinInitializationSettings()
    );

    await plugin.initialize(
      settings,
    );

    if(Platform.isAndroid) {
      plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> sendNotification(NotificationType type, {required String title, String body = ""}) async {
    plugin.show(type.index, title, body, NotificationDetails(
      android: AndroidNotificationDetails(
        type.notificationId, 'Bitcoin Fees Low',
        channelDescription: "Notifications sent when Bitcoin fees are below your set threshold.",
        importance: Importance.high,
        icon: 'ic_launcher_round',
        onlyAlertOnce: true,
      )
    ));
  }
}

enum NotificationType {
  feesBelowShortAverage("bitcoin-fees-below-short-average"),
  feesBelowLongAverage("bitcoin-fees-below-long-average"),
  feesBelowThreshold("bitcoin-fees-below-threshold");

  final String notificationId;
  int get intId => index;

  const NotificationType(this.notificationId);
}