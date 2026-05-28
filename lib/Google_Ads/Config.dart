import 'package:get/get.dart';
import 'package:note_app/Google_Ads/ConfigController.dart';
import 'package:note_app/Google_Ads/ConfigModel.dart';

class Config {
  ConfigController configController = Get.find<ConfigController>();

  openAdUnitId() async {
    ConfigModel? config =
        await configController.getConfigFromSharedPreferences();
    return config?.googleAppOpenAds;
  }

  interstitialAdUnitId() async {
    ConfigModel? config =
        await configController.getConfigFromSharedPreferences();
    return config?.googleInterAds;
  }

  nativeAdUnitId() async {
    ConfigModel? config =
        await configController.getConfigFromSharedPreferences();
    return config?.googleNativeAds;
  }

  bannerAdUnitId() async {
    ConfigModel? config =
        await configController.getConfigFromSharedPreferences();
    return config?.googleBannerAds;
  }

  showAds() async {
    ConfigModel? config =
        await configController.getConfigFromSharedPreferences();
    return config?.extraParam.adsOnOff ?? false;
  }

  ifOpenAds() async {
    final ConfigModel? config =
        await configController.getConfigFromSharedPreferences();
    if (config != null) {
      return config.extraParam.whichOneSplashAppOpen;
    } else {
      // If config is not in shared preferences, wait for a bit
      await Future.delayed(const Duration(seconds: 2));
      final ConfigModel? configRetry =
          await configController.getConfigFromSharedPreferences();
      return configRetry?.extraParam.whichOneSplashAppOpen;
    }
  }

  intersClick() async {
    ConfigModel? config =
        await configController.getConfigFromSharedPreferences();
    return config?.extraParam.interIntervalCount ?? 0;
  }

  intersBackClick() async {
    ConfigModel? config =
        await configController.getConfigFromSharedPreferences();
    return config?.extraParam.backInterIntervalCount;
  }

  String configUrl = "https://savaliya.xyz/appmanager/api/appsetting";
}
