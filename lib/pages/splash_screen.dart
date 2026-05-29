import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/Google_Ads/AppOpenAds/AppOpenManager.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/pages/main_page_screen.dart';
import 'package:note_app/pages/welcome_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStartup extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AppStartup({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  // How often to check if the ad is ready.
  static const _pollInterval = Duration(milliseconds: 500);
  // Max time to wait for the ad before giving up and going to home.
  static const _maxAdWait = Duration(seconds: 15);
  // Hard safety net — navigates no matter what after this.
  static const _absoluteTimeout = Duration(seconds: 45);

  bool _flowComplete = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();

    // Block showOnAppResume() from firing while the splash + ad are running.
    AppOpenAdManager.instance.setSplashInProgress(true);

    _safetyTimer = Timer(_absoluteTimeout, () {
      debugPrint('AppStartup: absolute timeout — forcing navigation.');
      _onFlowComplete();
    });

    _runStartupFlow();
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  Future<void> _runStartupFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final showWelcome = prefs.getBool('showWelcomePage') ?? true;

    // Poll until the ad is ready or the deadline passes.
    final deadline = DateTime.now().add(_maxAdWait);
    while (DateTime.now().isBefore(deadline)) {
      if (AppOpenAdManager.instance.isAdAvailable) break;
      await Future.delayed(_pollInterval);
    }

    if (!mounted) return;

    if (AppOpenAdManager.instance.isAdAvailable) {
      // Ad is ready — show it over the white splash screen.
      await ShowAppOpenAds.instance
          .showAppOpenAds(callback: () => _onFlowComplete(showWelcome: showWelcome));
    } else {
      // No ad available — navigate directly.
      _onFlowComplete(showWelcome: showWelcome);
    }
  }

  void _onFlowComplete({bool showWelcome = false}) {
    if (_flowComplete) return;
    _flowComplete = true;
    _safetyTimer?.cancel();
    AppOpenAdManager.instance.setSplashInProgress(false);

    if (showWelcome) {
      Get.offAll(
        () => WelcomePage(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
          onGetStarted: _onWelcomeFinished,
        ),
        transition: Transition.noTransition,
      );
    } else {
      Get.offAll(
        () => MainPage(toggleTheme: widget.toggleTheme),
        transition: Transition.noTransition,
      );
    }
  }

  Future<void> _onWelcomeFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcomePage', false);
    Get.offAll(
      () => MainPage(toggleTheme: widget.toggleTheme),
      transition: Transition.noTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Always show the splash — it stays visible behind the ad while it loads.
    // Navigation happens via Get.offAll() inside _onFlowComplete().
    return const _SplashView();
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Smart Notebook ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0XFF6096ba),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
