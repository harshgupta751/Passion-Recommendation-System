import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.drobe.app/v1';

  static String get googleClientId =>
      dotenv.env['GOOGLE_CLIENT_ID'] ?? '';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;

  // Hive box names
  static const String userBox = 'user_box';
  static const String closetBox = 'closet_box';
  static const String outfitsBox = 'outfits_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';

  // Secure storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // Pagination
  static const int pageSize = 20;

  // Item status labels
  static const String statusAvailable = 'available';
  static const String statusInUse = 'in_use';
  static const String statusInLaundry = 'in_laundry';
  static const String statusStored = 'stored';

  // Clothing categories
  static const List<String> categories = [
    'All',
    'Tops',
    'Bottoms',
    'Outerwear',
    'Footwear',
    'Accessories',
    'Formal',
    'Activewear',
    'Loungewear',
    'Bags',
  ];

  // Occasions
  static const List<String> occasions = [
    'Casual',
    'Formal',
    'Business',
    'Athletic',
    'Evening',
    'Date',
    'Travel',
    'Beach',
    'Festival',
  ];

  // Seasons
  static const List<String> seasons = [
    'All Season',
    'Spring',
    'Summer',
    'Autumn',
    'Winter',
  ];

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);
}