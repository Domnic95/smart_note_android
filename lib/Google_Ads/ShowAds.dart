import 'dart:async';
import 'dart:ui';

import 'package:note_app/Google_Ads/AppOpenAds/AppLifeCycleReactor.dart';
import 'package:note_app/Google_Ads/AppOpenAds/AppOpenManager.dart';
import 'package:note_app/Google_Ads/Config.dart';
import 'package:note_app/Google_Ads/InterstitialAds/InterstitialAdManager.dart';
import 'package:note_app/Google_Ads/SpHelper.dart';

class ShowAppOpenAds {
  late AppLifecycleReactor _appLifecycleReactor;
  late AppOpenAdManager _appOpenAdManager;
  int click = 0;

  showAppOpenAds({VoidCallback? callback}) async {
    if (await Config().ifOpenAds() == 1 && await Config().showAds()) {
      return initAppOpen(callback: callback);
    } else if (await Config().ifOpenAds() == 2 && await Config().showAds()) {
      return Future.delayed(const Duration(seconds: 2)).then((value) =>
          {ShowInterstitialAds().showInterstitialAds(callback: callback)});
    } else {
      if (callback != null) {
        Future.delayed(const Duration(seconds: 3))
            .then((value) => {callback()});
      }
    }
  }

  initAppOpen({VoidCallback? callback}) {
    _appOpenAdManager = AppOpenAdManager();
    _appOpenAdManager.loadAd();

    Timer(const Duration(seconds: 2), () {
      if (_appOpenAdManager.isAdAvailable) {
        _appOpenAdManager.showAdIfAvailable(onAdDismissed: callback);
      } else {
        if (callback != null) {
          callback();
        }
      }
    });
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: _appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
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
