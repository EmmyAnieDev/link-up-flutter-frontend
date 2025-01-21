import 'package:link_up/data/repositories/auth_repo.dart';

import '../../core/services/api_exception.dart';
import '../../core/services/api_service.dart';
import '../models/chat_list_model.dart';
import '../models/user_model.dart';

class UserRepository {
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
}
