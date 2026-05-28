import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/Google_Ads/Config.dart';
import 'package:note_app/Google_Ads/ConfigModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigController extends GetxController {
  var isCall = false;

  Future<bool> fetchConfig() async {
    try {
      final response = await http.post(Uri.parse(Config().configUrl),
          headers: {"Accept": "*/*"},
          body: {"packagename": "sdsdsds", "secretkey": "123"}).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final configModel = configModelFromJson(response.body.toString());
        log(configModelToJson(configModel).toString());
        await saveConfigToSharedPreferences(configModel);
        isCall = true;
        update();
        return true;
      } else {
        isCall = false;
        update();
        return false;
      }
    } catch (e) {
      log("Error fetching config: $e");
      isCall = false;
      update();
      return false;
    }
  }

  Future<void> saveConfigToSharedPreferences(ConfigModel configModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("configKey", configModelToJson(configModel));
    update();
  }

  Future<ConfigModel?> getConfigFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? configJson = prefs.getString("configKey");
    if (configJson != null) {
      return configModelFromJson(configJson);
    }
    update();
    return null;
  }
}
