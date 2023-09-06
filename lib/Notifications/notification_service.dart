import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await setupFlutterNotifications();
    showFlutterNotification(message);
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    print('Handling a background message ${message.messageId}');
  }




  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // id
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }
  // void requestNotificationService() async {
  //   NotificationSettings settings = await messaging.requestPermission(
  //       alert: true,
  //       carPlay: true,
  //       provisional: true,
  //       sound: true,
  //       announcement: true,
  //       badge: true,
  //       criticalAlert: true);
  //
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     print("Permission given..");
  //   } else {
  //     print("Permission not given..");
  //   }
  // }
  //
  // void initLocalNotificationPlugin(
  //     BuildContext context, RemoteMessage message) async {
  //   var androidInitializationSettings =
  //       const AndroidInitializationSettings("@mipmap/ic_launcher");
  //   var iosInitializationSettings = const DarwinInitializationSettings();
  //
  //   var intitalizeSettings = InitializationSettings(
  //     android: androidInitializationSettings,
  //     iOS: iosInitializationSettings,
  //   );
  //
  //   await flutterLocalNotificationsPlugin.initialize(intitalizeSettings,
  //       onDidReceiveNotificationResponse: (payload) {});
  // }
  //
  // void firebaseInit() {
  //   messaging = FirebaseMessaging.instance;
  //   //initLocalNotificationPlugin(context, message)
  //   FirebaseMessaging.onMessage.listen((message) {
  //     print(message.notification!.title.toString());
  //     print(message.notification!.body.toString());
  //    // showNotification(message);
  //   });
  //   //FirebaseMessaging.onMessageOpenedApp;
  //
  //   FirebaseMessaging.instance.getInitialMessage().then((message) {
  //     if (message != null) {
  //       // DO YOUR THING HERE
  //     }
  //   });
  //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //     // handle accordingly
  //     print("Noti 1 > ${message.notification!.title.toString()}");
  //     print("Noti 2 > ${message.notification!.body.toString()}");
  //     showNotification(message);
  //   });
  //
  //   messaging.getToken().then((value) {
  //     print("Tojen => ${value}");
  //   });
  // }
  //
  // Future<void> showNotification(RemoteMessage message) async {
  //   ///  AndroidNotificationChannel cha
  //   AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(Random.secure().nextInt(100000).toString(),
  //           "High Importance Notification",
  //           channelDescription: 'My notification',
  //           importance: Importance.high,
  //           priority: Priority.high,
  //           ticker: 'ticker');
  //
  //   DarwinNotificationDetails darwinNotificationDetails =
  //       const DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );
  //
  //   NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidNotificationDetails,
  //     iOS: darwinNotificationDetails,
  //   );
  //
  //   Future.delayed(Duration.zero, () {
  //     flutterLocalNotificationsPlugin.show(
  //         0,
  //         message.notification!.title.toString(),
  //         message.notification!.body.toString(),
  //         notificationDetails);
  //   });
  // }
  //
  // Future<String> getDeviceToken() async {
  //   String? token = await messaging.getToken();
  //   return token!;
  // }
  //
  // static void sendNotification() {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //   messaging.sendMessage(
  //       to: "eEyUBAzNSwiHaRCKqpOe1R:APA91bHbQee_WOztZKlzt47f7VDeQPLjNDPduMZOOyop5KZ_Jfk1xiLQhASjDe7SQr41SozMRNrLEDRVXMP1U4P3PkqWqYfNcarMvGkcX0F50ScDM24qpi_SeFiEdxJDRiOtzi-bPCV0",
  //       data: {
  //         "title": "Heeleleleel",
  //         "body": "Kya haala ha",
  //       });
  // }
}
