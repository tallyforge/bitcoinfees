import 'dart:io';

import 'package:bitcoinfees/background_processor.dart';
import 'package:bitcoinfees/data/preferences/app_prefs.dart';
import 'package:bitcoinfees/ui/screen/home.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    backgroundProcessor,
    isInDebugMode: kDebugMode,
  );
  Workmanager().registerPeriodicTask(
    "fee-check",
    "periodicTask",
    frequency: const Duration(minutes: 30),
    constraints: Constraints(
      networkType: NetworkType.connected,
    )
  );

  if(Platform.isAndroid) {
    var plugin = FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if(plugin != null) {
      await plugin.requestNotificationsPermission();
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppPrefs>(
      create: (_) => AppPrefs(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: SeedColorScheme.fromSeeds(
            primaryKey: const Color(0xfff7931a),
            tertiaryKey: const Color(0xffa0a3a4),
            brightness: Brightness.dark,
            inversePrimary: const Color(0xfff7931a),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(title: 'Bitcoin Fees'),  // by TallyForge
      ),
    );
  }
}

