import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:note_app/Google_Ads/Config.dart';

class BannerAdManager extends StatefulWidget {
  const BannerAdManager({super.key});

  @override
  State<BannerAdManager> createState() => _BannerAdManagerState();
}

class _BannerAdManagerState extends State<BannerAdManager> {
  BannerAd? _bannerAd;
  bool isLoaded = false;
  bool showBanner = false;

  @override
  initState() {
    super.initState();
    showBannerCheck();
  }

  showBannerCheck() async {
    showBanner = await Config().showAds() ?? false;

    if (showBanner) {
      await loadAd();
      setState(() {});
    }
  }

  Future<void> loadAd() async {
    _bannerAd = BannerAd(
      adUnitId: await Config().bannerAdUnitId(),
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('$ad loaded.');
          isLoaded = true;
          setState(() {});
        },
        onAdFailedToLoad: (ad, err) {
          log('BannerAd failed to loads: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return showBanner && isLoaded
        ? SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox();
  }
}
