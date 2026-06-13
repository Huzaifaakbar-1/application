import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

/// Entry-point called by the OS (or flutter_local_notifications background
/// isolate) when a scheduled notification fires while the app is terminated.
@pragma('vm:entry-point')
void notificationEntryPoint() {
  // No UI is required here; the notification plugin handles the display.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A14),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Notifications — must run before runApp
  await NotificationService.init();
  await NotificationService.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Daily Habits',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}