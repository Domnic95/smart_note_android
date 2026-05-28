import 'package:flutter/material.dart';
import 'package:note_app/Google_Ads/AppOpenAds/AppOpenManager.dart';
import 'package:note_app/pages/main_page_screen.dart';
import 'package:note_app/pages/welcome_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStartup extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final AppOpenAdManager appOpenAdManager;

  const AppStartup({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.appOpenAdManager,
  });

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  _StartupRoute _route = _StartupRoute.splash;

  static const Duration _splashMinDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _runStartupFlow();
  }

  Future<void> _runStartupFlow() async {
    // 1. Determine destination while splash is visible
    final prefs = await SharedPreferences.getInstance();
    final showWelcome = prefs.getBool('showWelcomePage') ?? true;
    final targetRoute =
        showWelcome ? _StartupRoute.welcome : _StartupRoute.main;

    // 2. Run splash timer and ad load wait in parallel.
    //    - Splash stays visible for at least _splashMinDuration.
    //    - Ad gets up to 5 s total to load (counted from app start, so if it
    //      loaded in <1.8 s the wait here is effectively zero).
    await Future.wait([
      Future<void>.delayed(_splashMinDuration),
      // Wait until the ad loads (with up to 3 retries on failure).
      // 20 s hard backstop covers GMS silent-failure edge cases.
      widget.appOpenAdManager.waitUntilReady(
        timeout: const Duration(seconds: 20),
      ),
    ]);
    if (!mounted) return;

    // 3. Show ad — navigation happens exclusively inside onAdDismissed.
    //    If the ad still isn't ready (network failure, ads disabled, etc.)
    //    showAdIfAvailable returns false and we navigate immediately.
    final adShown = widget.appOpenAdManager.showAdIfAvailable(
      onAdDismissed: () => _navigateTo(targetRoute),
    );

    if (!adShown) {
      _navigateTo(targetRoute);
    }
  }

  void _navigateTo(_StartupRoute target) {
    if (!mounted) return;
    setState(() => _route = target);
  }

  Future<void> _onWelcomeFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcomePage', false);
    if (!mounted) return;
    setState(() {
      _route = _StartupRoute.main;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_route) {
      case _StartupRoute.splash:
        return const _SplashView();
      case _StartupRoute.welcome:
        return WelcomePage(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
          onGetStarted: _onWelcomeFinished,
        );
      case _StartupRoute.main:
        return MainPage(
          toggleTheme: widget.toggleTheme,
        );
    }
  }
}

enum _StartupRoute { splash, welcome, main }

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
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
