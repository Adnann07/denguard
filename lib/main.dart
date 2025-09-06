import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'language_service.dart';
import 'dengue_home_page.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'splash_screen.dart';
import 'chat_screen.dart';
import 'nearby_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  printFCMToken();
//remote notif
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Message received: ${message.notification?.title}");
  });

  runApp(const DengueApp());
}

class DengueApp extends StatelessWidget {
  const DengueApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ChangeNotifierProvider(
      create: (context) => LanguageService(),
      child: MaterialApp(
        title: 'Denguard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/chatbot': (context) => const ChatScreen(),
          '/nearby-map': (context) => const ICUDirectoryPage(), // Nearby Map route
        },
      ),
    );
  }
}

void printFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("🔐 Your FCM Token: $token");
}
