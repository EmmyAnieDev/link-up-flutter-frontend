import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/api_exception.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cache_service.dart';

class ProfileImageRepository {
  static const String _imageCachePrefix = 'user_image_cache_';

  static Future<String> uploadUserPhoto(base64Image, token) async {
    try {
      // Convert base64 to bytes
      Uint8List imageBytes = base64Decode(base64Image);

      final response = await ApiService.uploadFile(
        'users/upload-photo',
        'file', // field name matching your backend
        imageBytes,
        'profile_image.jpg',
        token: token,
      );

      if (response == null || response.isEmpty) {
        throw ApiException('No response from server');
      }

      if (response is Map<String, dynamic>) {
        if (response['status'] == 422) {
          throw ApiException(
              'Image upload failed: Invalid image or size is higher than 2MB.');
        }

        if (response['status'] != 201 || response['success'] != true) {
          throw ApiException(response['message']);
        }

        final newImagePath = response['data']['image_path'] as String;

        // Clear previous image cache if exists
        final prefs = await SharedPreferences.getInstance();
        final previousImagePath = await retrieveCurrentUserImagePath();

        if (previousImagePath != null) {
          final previousCacheKey =
              _imageCachePrefix + previousImagePath.hashCode.toString();

          await prefs.remove(previousCacheKey);
        }

        return newImagePath;
      } else {
        throw ApiException('Invalid response format from server');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Photo upload failed: ${e.toString()}');
    }
  }

  static Future<Uint8List> retrieveUserPhoto(String path, String token) async {
    final prefs = await SharedPreferences.getInstance();

    // Generate a unique cache key based on the image path
    final cacheKey = _imageCachePrefix + path.hashCode.toString();

    // Check if image is cached
    final cachedImageBase64 = prefs.getString(cacheKey);

    if (cachedImageBase64 != null) {
      // Convert base64 back to Uint8List
      return base64Decode(cachedImageBase64);
    }

    try {
      final response = await ApiService.getFile(
        'users/get-photo',
        {'path': path},
        token,
      );

      if (response is Uint8List) {
        await CacheService.cacheImage(cacheKey, response);
        return response;
      } else {
        throw ApiException('Unexpected response format: Expected image bytes');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch user photo: ${e.toString()}');
    }
  }

  // Method to retrieve current user's image path
  static Future<String?> retrieveCurrentUserImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('currentUser');

    if (currentUser != null) {
      final currentUserData = json.decode(currentUser);
      return currentUserData['profile_photo'];
    }

    return null;
  }
}
