import 'dart:async';
import 'dart:developer';

import 'package:note_app/Google_Ads/Config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  AppOpenAdManager._();

  static final AppOpenAdManager instance = AppOpenAdManager._();

  final Duration maxCacheDuration = const Duration(hours: 4);
  DateTime? _appOpenLoadTime;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _splashInProgress = false;
  Future<bool>? _ongoingLoad;
  DateTime? _lastAdDismissedTime;
  static const _resumeCooldown = Duration(seconds: 30);

  bool get splashInProgress => _splashInProgress;

  void setSplashInProgress(bool value) {
    _splashInProgress = value;
  }

  // ── Load ──────────────────────────────────────────────────────────────────────

  Future<bool> loadAd({bool forceReload = false}) async {
    if (!forceReload && isAdAvailable) return true;
    if (!forceReload && _ongoingLoad != null) return _ongoingLoad!;

    final load = _performLoad();
    _ongoingLoad = load;
    try {
      return await load;
    } finally {
      if (identical(_ongoingLoad, load)) _ongoingLoad = null;
    }
  }

  Future<bool> _performLoad() async {
    if (!await Config().showAds()) return false;

    final adUnitId = await Config().openAdUnitId();
    if (adUnitId == null) {
      log('AppOpenAd: skipped — no unit ID in config');
      return false;
    }

    final completer = Completer<bool>();
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          debugPrint('AppOpenAd: loaded ✓');
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd: failed to load — $error');
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  bool get isAdAvailable => _appOpenAd != null;

  // ── Show ──────────────────────────────────────────────────────────────────────

  /// Cold-start: called only after the polling loop has confirmed
  /// [isAdAvailable]. Shows the ad over the white splash and awaits dismissal.
  /// Fires [onDismissed] when the ad closes (or immediately on error).
  Future<void> showOnColdStart({VoidCallback? onDismissed}) async {
    _splashInProgress = true;
    try {
      if (!isAdAvailable) return;

      final dismissed = Completer<void>();
      showAdIfAvailable(
        onAdDismissed: () {
          if (!dismissed.isCompleted) dismissed.complete();
        },
      );

      await dismissed.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {},
      );
    } finally {
      onDismissed?.call();
    }
  }

  /// App-resume: shows the ad when the app returns to foreground,
  /// guarded by [_resumeCooldown] and [_splashInProgress].
  Future<void> showOnAppResume() async {
    if (_splashInProgress || _isShowingAd) return;
    if (_lastAdDismissedTime != null &&
        DateTime.now().difference(_lastAdDismissedTime!) < _resumeCooldown) {
      return;
    }
    if (!await Config().showAds() || await Config().ifOpenAds() != 1) return;

    if (!isAdAvailable) await loadAd();
    if (isAdAvailable && !_isShowingAd && !_splashInProgress) {
      showAdIfAvailable();
    }
  }

  void showAdIfAvailable({VoidCallback? onAdDismissed}) {
    if (!isAdAvailable) {
      log('AppOpenAd: not available');
      unawaited(loadAd());
      onAdDismissed?.call();
      return;
    }
    if (_isShowingAd) {
      log('AppOpenAd: already showing');
      onAdDismissed?.call();
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      log('AppOpenAd: cache expired — reloading');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      unawaited(loadAd());
      onAdDismissed?.call();
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        log('AppOpenAd: showing');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('AppOpenAd: failed to show — $error');
        _isShowingAd = false;
        _lastAdDismissedTime = DateTime.now();
        ad.dispose();
        _appOpenAd = null;
        unawaited(loadAd());
        onAdDismissed?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        log('AppOpenAd: dismissed');
        _isShowingAd = false;
        _lastAdDismissedTime = DateTime.now();
        ad.dispose();
        _appOpenAd = null;
        unawaited(loadAd());
        onAdDismissed?.call();
      },
    );
    _appOpenAd!.show();
  }
}
