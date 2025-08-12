import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:zineapp2023/background/notification_handle.dart';
import 'package:zineapp2023/utilities/custom_logger.dart';
import './screens/onboarding/splash/splash.dart';
import './app_providers.dart';
import './common/data_store.dart';
import './providers/dictionary.dart';
import './providers/user_info.dart';
import './common/navigator.dart';

import 'database/database.dart';

final Language _language = Language();

final logger = customLogger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _language.init();


  Logger.level = Level.warning; //Edit this to get more deep logs
  await initializeNotifications();

  AppDb db = AppDb();
  await db.roomDao.initializeIsSyncedColumn();

  DataStore store = DefaultStore();
  UserProv userProv = UserProv(dataStore: store, db: db);
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  runApp(MyApp(
      store: store, userProv: userProv, secureStorage: secureStorage, db: db));
}

class MyApp extends StatelessWidget {
  final DataStore store;
  final UserProv userProv;
  final FlutterSecureStorage secureStorage;
  final AppDb db;

  const MyApp(
      {super.key,
      required this.store,
      required this.userProv,
      required this.secureStorage,
      required this.db});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      language: _language,
      userProv: userProv,
      store: store,
      db: db,
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        title: 'Zine',
        theme: ThemeData(
            fontFamily: 'Poppins',
            primarySwatch: Colors.blue,
            useMaterial3: false),
        home: const SplashScreen(),
      ),
    );
  }
}
