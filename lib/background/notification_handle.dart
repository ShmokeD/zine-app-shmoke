import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:provider/provider.dart';
import 'package:zineapp2023/background/firebase_options.dart';
import 'package:zineapp2023/common/navigator.dart';
import 'package:zineapp2023/screens/chat/chat_screen/view_model/chat_room_view_model.dart';
import 'package:zineapp2023/utilities/custom_logger.dart';
import '../../../database/database.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final logger = customLogger();

Future<void> initializeNotifications() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    criticalAlert: true,
  );

  await messaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  await FlutterNotificationChannel().registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');

  const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'));

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen(foregroundMessageCallback);
}


Future<void> _showNotification({String? title, String? body}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('chats', 'Chats',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@drawable/zine_logo1');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

void foregroundMessageCallback(RemoteMessage message) async {
  logger.t(
      "message data:${message.data}  message notification data:${message.notification?.body}");

  if (message.notification != null) {
    //Get the currently visible room's context.
    ChatRoomViewModel chatRoomView = Provider.of<ChatRoomViewModel>(
        NavigationService.navigatorKey.currentContext!,
        listen: false);

    var db = Provider.of<AppDb>(NavigationService.navigatorKey.currentContext!,
        listen: false);

    logger.d("message roomID:${message.data['roomId']}");
    logger.d("chatRoomView.roomId:${chatRoomView.currRoomId}");

    //Also Sync other rooms when we are notified of a change
    chatRoomView.fetchAllRoomDataFromApiAndSyncWithDB(db);

    // Only Show notification if its not about our current room
    if (message.data['roomId'] != chatRoomView.currRoomId) {
      await _showNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
    }
  }
}
