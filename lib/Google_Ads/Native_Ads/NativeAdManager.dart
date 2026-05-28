import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:note_app/Google_Ads/Config.dart';

class NativeAdManager extends StatefulWidget {
  const NativeAdManager({super.key});

  @override
  State<NativeAdManager> createState() => _NativeAdManagerState();
}

class _NativeAdManagerState extends State<NativeAdManager> {
  NativeAd? _nativeAd;
  bool nativeAdIsLoaded = false;
  bool showNative = false;
  @override
  initState() {
    super.initState();
    showNativeCheck();
  }

  showNativeCheck() async {
    showNative = await Config().showAds();

    if (showNative) {
      await loadAd();
      setState(() {});
    }
  }

  Future<void> loadAd() async {
    _nativeAd = NativeAd(
        adUnitId: await Config().nativeAdUnitId(),
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$ad loaded.');
            nativeAdIsLoaded = true;
            setState(() {});
          },
          onAdFailedToLoad: (ad, err) {
            log('Native failed to loads: $err');
            ad.dispose();
          },
        ),
        factoryId: "listTile")
      ..load();
  }

  @override
  Widget build(BuildContext context) {
    // 140dp matches the layout's intrinsic content height:
    //   8dp top padding + 48dp icon row + 4dp + ~28dp body (2 lines)
    //   + 8dp + 36dp Install button + 8dp bottom padding ≈ 140dp.
    // Larger values leave empty space below the card.
    return showNative && nativeAdIsLoaded
        ? SizedBox(height: 140, child: AdWidget(ad: _nativeAd!))
        : const SizedBox();
  }
}
