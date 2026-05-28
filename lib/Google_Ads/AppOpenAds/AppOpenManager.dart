import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:note_app/Google_Ads/Config.dart';

class AppOpenAdManager {
  final Duration maxCacheDuration = const Duration(hours: 4);
  DateTime? _appOpenLoadTime;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  // Completer that resolves when the ad is available OR definitively failed.
  // Created synchronously before the first await in loadAd() so that
  // waitUntilReady() always has a non-null future to await.
  Completer<void>? _loadCompleter;
  bool _completerDone = false;

  int _retryCount = 0;
  static const int _maxRetries = 3;

  void _completeLoad() {
    if (!_completerDone) {
      _completerDone = true;
      _loadCompleter?.complete();
    }
  }

  Future<void> loadAd({VoidCallback? onLoaded, bool isRetry = false}) async {
    if (!isRetry) {
      // First call — create a fresh completer synchronously so waitUntilReady()
      // called on the very next frame already has something to await.
      _loadCompleter = Completer<void>();
      _completerDone = false;
      _retryCount = 0;
    }

    bool canShowAds = await Config().showAds();
    String? adUnitId = await Config().openAdUnitId();

    debugPrint('AppOpenAd: canShowAds=$canShowAds adUnitId=$adUnitId retryCount=$_retryCount');

    if (!canShowAds || adUnitId == null) {
      debugPrint('AppOpenAd: ads disabled or no unit ID');
      _completeLoad();
      return;
    }

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          _retryCount = 0;
          debugPrint('AppOpenAd: loaded ✓');
          _completeLoad();
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd: failed ($error) — retry $_retryCount/$_maxRetries');
          if (_retryCount < _maxRetries) {
            _retryCount++;
            // Brief delay before retry to avoid hammering the server
            Future.delayed(const Duration(seconds: 2), () {
              loadAd(onLoaded: onLoaded, isRetry: true);
            });
          } else {
            debugPrint('AppOpenAd: all retries exhausted — giving up');
            _completeLoad(); // release the splash so the user isn't stuck
          }
        },
      ),
    );
  }

  /// Waits until the ad is loaded OR all retries are exhausted.
  /// The [timeout] is a hard backstop for the case where the SDK fires
  /// no callbacks at all (GMS service silent failure).
  Future<bool> waitUntilReady({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (isAdAvailable) return true;
    final completer = _loadCompleter;
    if (completer == null) return false;
    try {
      await completer.future.timeout(timeout);
    } on TimeoutException {
      debugPrint('AppOpenAd: hard timeout after $timeout — SDK was silent');
    }
    return isAdAvailable;
  }

  bool get isAdAvailable => _appOpenAd != null;

  /// Shows the ad if available. Returns true if the ad was shown.
  bool showAdIfAvailable({VoidCallback? onAdDismissed}) {
    if (!isAdAvailable) {
      log('AppOpenAd: not available');
      return false;
    }
    if (_isShowingAd) {
      log('AppOpenAd: already showing');
      return false;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      log('AppOpenAd: cache expired — reloading');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      return false;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        log('AppOpenAd: showing');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('AppOpenAd: failed to show: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        log('AppOpenAd: dismissed');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // pre-load next ad for lifecycle reactor
        onAdDismissed?.call();
      },
    );

    _appOpenAd!.show();
    return true;
  }
}
