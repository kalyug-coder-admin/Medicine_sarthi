import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';        // ← KEEP THIS
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'injection_container.dart' as di;
import 'core/services/notification_service.dart';
import 'core/services/tts_service.dart';

// THIS IS REQUIRED FOR WORKMANAGER v0.9+
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final tts = TtsService();
    await tts.initialize();
    await tts.speak("Time to take medicine");
    await tts.stop();
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  tz.initializeTimeZones();
  await di.init();

  // Register TTS
  di.sl<NotificationService>().registerTtsService(di.sl<TtsService>());

  // Initialize notifications + custom sound
  await di.sl<NotificationService>().initialize();

  // Initialize Workmanager (NEW API)
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Portrait lock + status bar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}