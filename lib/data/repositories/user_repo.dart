import 'dart:convert';
import 'dart:typed_data';

import 'package:link_up/data/repositories/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/api_exception.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cache_service.dart';
import '../models/chat_list_model.dart';
import '../models/user_model.dart';

class UserRepository {
  static const String _imageCachePrefix = 'user_image_cache_';

  static Future<Map<String, dynamic>> updateUser(User user, token) async {
    try {
      final Map<String, dynamic> payload = {
        'name': user.name,
        'email': user.email,
      };

      final response =
          await ApiService.putRequest('users/update-profile', payload, token);

      if (response == null || response.isEmpty) {
        throw ApiException('No response from server');
      }

      if (response is Map<String, dynamic>) {
        if (response['status'] == 422) {
          throw ApiException(
              'User update failed: Email must be valid email address');
        }

        if (response['status'] != 200 || response['success'] != true) {
          throw ApiException(response['message']);
        }

        return response['data'];
      } else {
        throw ApiException('Invalid response format from server');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Update failed: ${e.toString()}');
    }
  }

  static Future<void> deleteUser(token) async {
    try {
      await AuthRepository.storage.delete(key: 'token');
      print("Token cleared locally.");

      await ApiService.deleteRequest('users/delete-account', token);

      print("Account deleted from database.");
    } catch (e) {
      print('Account deleted failed: ${e.toString()}');
      throw ApiException('Account deleted failed: ${e.toString()}');
    }
  }

  static Future<List<ChatListModel>> fetchAppUsers(String token) async {
    try {
      final response = await ApiService.getRequest('users', token);

      if (response == null || response.isEmpty) {
        throw ApiException('No response from server');
      }

      if (response is Map<String, dynamic>) {
        if (response['status'] != 200 || response['success'] != true) {
          throw ApiException(response['message']);
        }

        final List<dynamic> data = response['data'];
        return data.map((chat) => ChatListModel.fromMap(chat)).toList();
      } else {
        throw ApiException('Invalid response format from server');
      }
    } catch (e) {
      throw Exception('Failed to fetch App users: $e');
    }
  }

  static Future<Uint8List?> fetchAppUsersProfilePhoto(path, token) async {
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
      }
      return null;
    } catch (e) {
      print('Error fetching profile photo: $e');
      return null;
    }
  }
}
