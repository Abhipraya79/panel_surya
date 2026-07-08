import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp();
  }

  runApp(const PanelCareApp());
}

class PanelCareApp extends StatefulWidget {
  const PanelCareApp({super.key});

  @override
  State<PanelCareApp> createState() => _PanelCareAppState();
}

class _PanelCareAppState extends State<PanelCareApp> {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  @override
  void initState() {
    super.initState();

    if (defaultTargetPlatform == TargetPlatform.android) {
      setupFCM();
      listenForegroundNotifications();
    }
  }

  Future<void> setupFCM() async {
    final settings = await messaging.requestPermission();
    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    final token = await messaging.getToken();
    debugPrint('FCM Token: $token');
  }

  void listenForegroundNotifications() {
    _foregroundMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notif masuk: ${message.notification?.title}');
    });
  }

  @override
  void dispose() {
    _foregroundMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
