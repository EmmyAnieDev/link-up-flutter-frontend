import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/services/api_exception.dart';
import '../../core/services/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  static const storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> registerUser(User user) async {
    try {
      final response = await ApiService.postRequest(
          'register', user.toJson(includePassword: true));

      if (response == null || response.isEmpty) {
        throw ApiException('No response from server');
      }

      if (response is Map<String, dynamic>) {
        if (response['status'] == 422) {
          throw ApiException('Registration Failed: Email already exists');
        }

        if (response['status'] != 201 || response['success'] != true) {
          throw ApiException(response['message']);
        }

        final responseData = response['data'];

        if (!responseData.containsKey('token')) {
          throw ApiException('Missing token data in response');
        }

        await storeToken(responseData['token']);

        final userData = responseData['user'];
        if (userData is Map<String, dynamic>) {
          return {
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'created_at': userData['created_at'],
            'updated_at': userData['updated_at'],
          };
        } else {
          throw ApiException('Invalid user data format');
        }
      } else {
        throw ApiException('Invalid response format from server');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Registration failed: ${e.toString()}');
    }
  }

  static Future<User> loginUser(String email, String password) async {
    try {
      final response = await ApiService.postRequest('login', {
        'email': email,
        'password': password,
      });

      if (response == null || response.isEmpty) {
        throw ApiException('No response from server');
      }

      if (response is Map<String, dynamic>) {
        if (response['status'] == 422) {
          throw ApiException('Login Failed: User does not exists');
        }

        if (response['status'] != 200 || response['success'] != true) {
          throw ApiException(response['message']);
        }

        final responseData = response['data'];
        print(
            " ${response['status']}, ${response['message']}, ${responseData['token']}");

        if (!responseData.containsKey('token')) {
          throw ApiException('Missing token data in response');
        }

        await storeToken(responseData['token']);

        return User.fromJson(responseData['user']);
      } else {
        throw ApiException('Invalid response format from server');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login failed: ${e.toString()}');
    }
  }

  static Future<void> logoutUser(token) async {
    try {
      await ApiService.postRequest(
        'logout',
        {'token': token},
        token: token,
      );

      await storage.delete(key: 'token');
    } catch (e) {
      throw ApiException('Logout failed: ${e.toString()}');
    }
  }

  static Future<void> storeToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  static Future<String?> retrieveToken() async {
    return await storage.read(key: 'token');
  }
}
