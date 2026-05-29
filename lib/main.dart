// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:note_app/FIrebaseCrashlytics.dart';
import 'package:note_app/Google_Ads/AppOpenAds/AppOpenManager.dart';
import 'package:note_app/Google_Ads/ConfigController.dart';
import 'package:note_app/firebase_options.dart';
import 'package:note_app/pages/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:note_app/styles/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kPrefIsDark = 'isDark';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final initialThemekMode = prefs.getBool(_kPrefIsDark) ?? false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  developer.log('Loading .env file from the root directory.', name: 'main.dart');
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    developer.log('Error loading .env file: $e', name: 'main.dart');
  }

  await FIrebaseCrashlytics().crashlyticsInit();
  await MobileAds.instance.initialize();
  final configController = Get.put(ConfigController());
  await configController.fetchConfig();

  runApp(MyApp(initialDarkMode: initialThemekMode));

  // Kick off the ad load in the background after the app starts rendering.
  // The splash screen awaits it via AppOpenAdManager.instance.showOnColdStart().
  AppOpenAdManager.instance.loadAd();
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;

  const MyApp({super.key, required this.initialDarkMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  void _toggleTheme() {
    final next = !_isDarkMode;
    setState(() => _isDarkMode = next);
    SharedPreferences.getInstance().then((p) => p.setBool(_kPrefIsDark, next));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notebook',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AppStartup(
        toggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}
