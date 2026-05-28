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
    } else {
      Get.dialog(
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(.8),
          Center(
            child: Container(
              padding: const EdgeInsets.all(50),
              child: Lottie.asset("assets/loader/loader.json"),
            ),
          ));
      InterstitialAd.load(
          adUnitId: await Config().interstitialAdUnitId(),
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              log('$ad loaded.');
              Navigator.of(Get.overlayContext!).pop();
              isLoaded = true;
              interstitialAd = ad;
              interstitialAd?.show();
              ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  if (callback != null) {
                    callback();
                  }
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  if (callback != null) {
                    callback();
                  }
                },
              );
            },
            // Called when an ad request failed.
            onAdFailedToLoad: (LoadAdError error) {
              Navigator.of(Get.overlayContext!).pop();
              log('InterstitialAd failed to load: $error');
              isLoaded = false;
              if (callback != null) {
                callback();
              }
            },
          ));
    }
    // Future.delayed(const Duration(seconds: 2)).then((value) {
    //   interstitialAd?.show();
    // });
  }
}
