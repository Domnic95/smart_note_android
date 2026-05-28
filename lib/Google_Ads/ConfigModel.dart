// To parse this JSON data, do
//
//     final configModel = configModelFromJson(jsonString);

import 'dart:convert';

ConfigModel configModelFromJson(String str) =>
    ConfigModel.fromJson(json.decode(str));

String configModelToJson(ConfigModel data) => json.encode(data.toJson());

class ConfigModel {
  final String type;
  final String vpnOnOff;
  final String showDialogBeforeAds;
  final String googleAppOpenAds;
  final String google2AppOpenAds;
  final String googleBannerAds;
  final String google2BannerAds;
  final String google3BannerAds;
  final String googleInterAds;
  final String google2InterAds;
  final String google3InterAds;
  final String googleNativeAds;
  final String googleNative2Ads;
  final String google2NativeAds;
  final String google2Native2Ads;
  final String googleRewardAds;
  final String googleReward1Ads;
  final String fNative;
  final String fBanner;
  final String fInterstitial;
  final String fNativeBanner;
  final String vpnCarrierId;
  final String qurl;
  final String qUrlClick;
  final String country;
  final String state;
  final String city;
  final String vpnCode;
  final String clickcountry;
  final String clickcity;
  final String clickcountinter;
  final String commingSoon;
  final String isUpdate;
  final String updateUrl;
  final String privacyPolice;
  final bool error;
  final bool success;
  final ExtraParam extraParam;

  ConfigModel({
    required this.type,
    required this.vpnOnOff,
    required this.showDialogBeforeAds,
    required this.googleAppOpenAds,
    required this.google2AppOpenAds,
    required this.googleBannerAds,
    required this.google2BannerAds,
    required this.google3BannerAds,
    required this.googleInterAds,
    required this.google2InterAds,
    required this.google3InterAds,
    required this.googleNativeAds,
    required this.googleNative2Ads,
    required this.google2NativeAds,
    required this.google2Native2Ads,
    required this.googleRewardAds,
    required this.googleReward1Ads,
    required this.fNative,
    required this.fBanner,
    required this.fInterstitial,
    required this.fNativeBanner,
    required this.vpnCarrierId,
    required this.qurl,
    required this.qUrlClick,
    required this.country,
    required this.state,
    required this.city,
    required this.vpnCode,
    required this.clickcountry,
    required this.clickcity,
    required this.clickcountinter,
    required this.commingSoon,
    required this.isUpdate,
    required this.updateUrl,
    required this.privacyPolice,
    required this.error,
    required this.success,
    required this.extraParam,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        type: json["type"],
        vpnOnOff: json["VpnOnOff"],
        showDialogBeforeAds: json["ShowDialogBeforeAds"],
        googleAppOpenAds: json["GoogleAppOpenAds"],
        google2AppOpenAds: json["Google2AppOpenAds"],
        googleBannerAds: json["GoogleBannerAds"],
        google2BannerAds: json["Google2BannerAds"],
        google3BannerAds: json["Google3BannerAds"],
        googleInterAds: json["GoogleInterAds"],
        google2InterAds: json["Google2InterAds"],
        google3InterAds: json["Google3InterAds"],
        googleNativeAds: json["GoogleNativeAds"],
        googleNative2Ads: json["GoogleNative2Ads"],
        google2NativeAds: json["Google2NativeAds"],
        google2Native2Ads: json["Google2Native2Ads"],
        googleRewardAds: json["GoogleRewardAds"],
        googleReward1Ads: json["GoogleReward1Ads"],
        fNative: json["f_native"],
        fBanner: json["f_banner"],
        fInterstitial: json["f_interstitial"],
        fNativeBanner: json["f_native_banner"],
        vpnCarrierId: json["VpnCarrierId"],
        qurl: json["qurl"],
        qUrlClick: json["q_url_click"],
        country: json["Country"],
        state: json["State"],
        city: json["City"],
        vpnCode: json["VpnCode"],
        clickcountry: json["clickcountry"],
        clickcity: json["clickcity"],
        clickcountinter: json["clickcountinter"],
        commingSoon: json["comming_soon"],
        isUpdate: json["is_update"],
        updateUrl: json["update_url"],
        privacyPolice: json["privacy_police"],
        error: json["error"],
        success: json["success"],
        extraParam: ExtraParam.fromJson(json["extra_param"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "VpnOnOff": vpnOnOff,
        "ShowDialogBeforeAds": showDialogBeforeAds,
        "GoogleAppOpenAds": googleAppOpenAds,
        "Google2AppOpenAds": google2AppOpenAds,
        "GoogleBannerAds": googleBannerAds,
        "Google2BannerAds": google2BannerAds,
        "Google3BannerAds": google3BannerAds,
        "GoogleInterAds": googleInterAds,
        "Google2InterAds": google2InterAds,
        "Google3InterAds": google3InterAds,
        "GoogleNativeAds": googleNativeAds,
        "GoogleNative2Ads": googleNative2Ads,
        "Google2NativeAds": google2NativeAds,
        "Google2Native2Ads": google2Native2Ads,
        "GoogleRewardAds": googleRewardAds,
        "GoogleReward1Ads": googleReward1Ads,
        "f_native": fNative,
        "f_banner": fBanner,
        "f_interstitial": fInterstitial,
        "f_native_banner": fNativeBanner,
        "VpnCarrierId": vpnCarrierId,
        "qurl": qurl,
        "q_url_click": qUrlClick,
        "Country": country,
        "State": state,
        "City": city,
        "VpnCode": vpnCode,
        "clickcountry": clickcountry,
        "clickcity": clickcity,
        "clickcountinter": clickcountinter,
        "comming_soon": commingSoon,
        "is_update": isUpdate,
        "update_url": updateUrl,
        "privacy_police": privacyPolice,
        "error": error,
        "success": success,
        "extra_param": extraParam.toJson(),
      };
}

class ExtraParam {
  bool adsOnOff;
  int interIntervalCount;
  int backInterIntervalCount;
  int whichOneSplashAppOpen;

  ExtraParam({
    required this.adsOnOff,
    required this.interIntervalCount,
    required this.backInterIntervalCount,
    required this.whichOneSplashAppOpen,
  });

  factory ExtraParam.fromJson(Map<String, dynamic> json) => ExtraParam(
        adsOnOff: json["AdsOnOff"],
        interIntervalCount: json["InterIntervalCount"],
        backInterIntervalCount: json["BackInterIntervalCount"],
        whichOneSplashAppOpen: json["WhichOneSplashAppOpen"],
      );

  Map<String, dynamic> toJson() => {
        "AdsOnOff": adsOnOff,
        "InterIntervalCount": interIntervalCount,
        "BackInterIntervalCount": backInterIntervalCount,
        "WhichOneSplashAppOpen": whichOneSplashAppOpen,
      };
}
