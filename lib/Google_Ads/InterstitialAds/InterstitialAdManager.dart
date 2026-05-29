import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:note_app/Google_Ads/Config.dart';

class InterstitialAdManager {
  InterstitialAd? interstitialAd;
  bool isLoaded = false;

  Future<void> loadAd({VoidCallback? callback}) async {
    if (await Config().ifOpenAds() == false &&
        await Config().showAds() == false) {
      log("message");
      if (callback != null) {
        callback();
      }
      return;
    }

    // Show loading spinner while the ad fetches.
    Get.dialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(.8),
      Center(
        child: Container(
          padding: const EdgeInsets.all(50),
          child: Lottie.asset("assets/loader/loader.json"),
        ),
      ),
    );

    InterstitialAd.load(
      adUnitId: await Config().interstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) async {
          log('$ad loaded.');
          // Dismiss the loading spinner.
          Navigator.of(Get.overlayContext!).pop();

          isLoaded = true;
          interstitialAd = ad;

          // Push a solid black screen so the app's AppBar / UI doesn't bleed
          // through the top of the native ad overlay.
          Get.to(
            () => const Scaffold(backgroundColor: Colors.black),
            routeName: '/AdBlackCover',
            transition: Transition.noTransition,
            duration: Duration.zero,
          );

          // Give the black screen one frame to paint before the ad appears.
          await Future.delayed(const Duration(milliseconds: 100));

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // Remove the black cover and run the callback.
              Get.back();
              ad.dispose();
              callback?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('InterstitialAd failed to show: $error');
              Get.back();
              ad.dispose();
              callback?.call();
            },
          );

          interstitialAd?.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          Navigator.of(Get.overlayContext!).pop();
          log('InterstitialAd failed to load: $error');
          isLoaded = false;
          callback?.call();
        },
      ),
    );
  }
}
