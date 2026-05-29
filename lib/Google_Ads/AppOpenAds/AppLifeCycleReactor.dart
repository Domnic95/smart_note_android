import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:note_app/Google_Ads/AppOpenAds/AppOpenManager.dart';

class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;
  bool _listening = false;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    if (_listening) return; // guard against duplicate listeners
    _listening = true;
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    log('AppState: $appState');
    if (appState == AppState.foreground) {
      appOpenAdManager.showOnAppResume();
    }
  }
}
