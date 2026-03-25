import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Future.wait([
      Hive.openBox('user_box'),
      Hive.openBox('closet_box'),
      Hive.openBox('outfits_box'),
      Hive.openBox('settings_box'),
      Hive.openBox('cache_box'),
    ]);
  }

  static Box get userBox => Hive.box('user_box');
  static Box get closetBox => Hive.box('closet_box');
  static Box get outfitsBox => Hive.box('outfits_box');
  static Box get settingsBox => Hive.box('settings_box');
  static Box get cacheBox => Hive.box('cache_box');
}