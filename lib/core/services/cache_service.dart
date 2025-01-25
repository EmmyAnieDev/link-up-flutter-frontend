import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static Future<void> cacheImage(String cacheKey, Uint8List imageBytes) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert image bytes to base64 string
    final base64Image = base64Encode(imageBytes);

    await prefs.setString(cacheKey, base64Image);
  }
}
