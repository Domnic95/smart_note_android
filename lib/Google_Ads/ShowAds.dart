import 'dart:async';
import 'dart:ui';

import 'package:note_app/Google_Ads/AppOpenAds/AppLifeCycleReactor.dart';
import 'package:note_app/Google_Ads/AppOpenAds/AppOpenManager.dart';
import 'package:note_app/Google_Ads/Config.dart';
import 'package:note_app/Google_Ads/InterstitialAds/InterstitialAdManager.dart';
import 'package:note_app/Google_Ads/SpHelper.dart';

class ShowAppOpenAds {
  ShowAppOpenAds._();

  static final ShowAppOpenAds instance = ShowAppOpenAds._();
  factory ShowAppOpenAds() => instance;

  AppLifecycleReactor? _appLifecycleReactor;
  final AppOpenAdManager _appOpenAdManager = AppOpenAdManager.instance;

  Future<void> showAppOpenAds({VoidCallback? callback}) async {
    final showAds = await Config().showAds();
    final openType = await Config().ifOpenAds();

    if (openType == 1 && showAds) {
      await initAppOpen(callback: callback);
      return;
    }
    callback?.call();
  }

  Future<void> initAppOpen({VoidCallback? callback}) async {
    await _appOpenAdManager.showOnColdStart(onDismissed: callback);
    // Delay attaching the lifecycle listener to avoid the spurious foreground
    // event the OS fires right after AdActivity closes in release mode.
    Future.delayed(const Duration(seconds: 5), _attachLifecycleListener);
  }

  void _attachLifecycleListener() {
    if (_appLifecycleReactor != null) return;
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: _appOpenAdManager);
    _appLifecycleReactor!.listenToAppStateChanges();
  }
}

class ShowInterstitialAds {
  InterstitialAdManager adManager = InterstitialAdManager();

  showClickInterstitialAds({VoidCallback? callback}) async {
    await SpHelper().initialize();

    int currentClick = await SpHelper.getclick();

    int interval = await Config().intersClick();
    if (interval != 0 &&
        currentClick % interval == 0 &&
        await Config().showAds()) {
      if (await Config().showAds()) {
        adManager.loadAd(callback: callback);
        await SpHelper.resetClick();
      }
    } else {
      if (callback != null) {
        callback();
      }
    }
    await SpHelper.incrementClick();
  }

  showBackClickInterstitialAds({VoidCallback? callback}) async {
    await SpHelper().initialize();

    int currentClick = await SpHelper.getBackclick();

    int interval = await Config().intersBackClick();

    if (interval != 0 &&
        currentClick % interval == 0 &&
        await Config().showAds()) {
      if (await Config().showAds()) {
        adManager.loadAd(callback: callback);
        await SpHelper.resetBackClick();
      }
    } else {
      if (callback != null) {
        callback();
      }
    }
    await SpHelper.incrementBackClick();
    return true;
  }

  showInterstitialAds({VoidCallback? callback}) {
    adManager.loadAd(callback: callback);
  }
}
