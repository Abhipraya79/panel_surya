import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'core/services/fcm_service.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/monitoring/presentation/providers/history_provider.dart';
import 'core/constants/app_config.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    debugPrint("✅ Firebase Initialized Successfully");
  } catch (e) {
    debugPrint("❌ Firebase Initialization Error: $e");
  }

  debugPrint('Backend URL:');
  debugPrint(AppConfig.baseUrl);
  debugPrint('');
  debugPrint('Socket URL:');
  debugPrint(AppConfig.socketUrl);

  runApp(const PanelCareApp());
}

class PanelCareApp extends StatefulWidget {
  const PanelCareApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  State<PanelCareApp> createState() => _PanelCareAppState();
}

class _PanelCareAppState extends State<PanelCareApp> {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  @override
  void initState() {
    super.initState();

    setupFCM();
    listenForegroundNotifications();
  }

  Future<void> setupFCM() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        "🔔 FCM Permission Status: ${settings.authorizationStatus}",
      );

      final token = await messaging.getToken();

      if (token != null) {
        debugPrint("📱 FCM Token:");
        debugPrint(token);
      } else {
        debugPrint("⚠️ FCM Token is null");
      }
    } catch (e) {
      debugPrint("❌ Error setting up FCM: $e");
    }
  }

  void listenForegroundNotifications() {
    _foregroundMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("========== FOREGROUND NOTIFICATION ==========");

      if (message.notification != null) {
        debugPrint("Title : ${message.notification!.title}");
        debugPrint("Body  : ${message.notification!.body}");
      }

      if (message.data.isNotEmpty) {
        debugPrint("Data  : ${message.data}");
      }

      debugPrint("============================================");
    });
  }

  @override
  void dispose() {
    _foregroundMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider()..initialize(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider()..loadHistory(),
        ),
      ],
      child: MaterialApp(
        title: 'Panel Care',
        scaffoldMessengerKey: PanelCareApp.scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}