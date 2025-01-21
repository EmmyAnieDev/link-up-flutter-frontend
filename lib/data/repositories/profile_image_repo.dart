import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/services/api_exception.dart';
import '../../core/services/api_service.dart';

class ProfileImageRepository {
  static Future<String> uploadUserPhoto(
      String base64Image, String token) async {
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

        return response['data']['image_path'] as String;
      } else {
        throw ApiException('Invalid response format from server');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Photo upload failed: ${e.toString()}');
    }
  }

  static Future<Uint8List> retrieveUserPhoto(String path, String token) async {
    try {
      final response = await ApiService.getFile(
        'users/get-photo',
        {'path': path},
        token,
      );

      if (response is Uint8List) {
        return response;
      } else {
        throw ApiException('Unexpected response format: Expected image bytes');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch user photo: ${e.toString()}');
    }
  }
}
