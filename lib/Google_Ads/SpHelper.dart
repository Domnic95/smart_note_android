import 'package:shared_preferences/shared_preferences.dart';

class SpHelper {
  static late SharedPreferences _preferences;

  initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> incrementClick() async {
    int click = await getclick();
    _preferences.setInt("click_count", click + 1);
  }

  static Future<int> getclick() async {
    return _preferences.getInt("click_count") ?? 0;
  }

  static Future<void> resetClick() async {
    _preferences.remove("click_count");
  }

  static Future<void> incrementBackClick() async {
    int click = await getclick();
    _preferences.setInt("click_count_back", click + 1);
  }

  static Future<int> getBackclick() async {
    return _preferences.getInt("click_count_back") ?? 0;
  }

  static Future<void> resetBackClick() async {
    _preferences.remove("click_count_back");
  }
}
