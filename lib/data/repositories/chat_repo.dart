import 'package:link_up/core/services/api_service.dart';

class ChatRepository {
  static Future<List<Map<String, dynamic>>> fetchMessages(
      String otherUserId, String token) async {
    try {
      final response = await ApiService.getRequest(
          'users/fetch-messages?other_user_id=$otherUserId', token);

      if (response['status'] == 200 && response['messages'] != null) {
        return List<Map<String, dynamic>>.from(response['messages']);
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  static Future<bool> sendMessage(
      String message, String receiverId, String token) async {
    try {
      final response = await ApiService.postRequest(
        'users/send-message',
        {
          'message': message,
          'receiver_id': receiverId,
        },
        token: token,
      );

      if (response['status'] == 201 || response['status'] == 200) {
        return true;
      } else {
        print('Error sending message: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception sending message: $e');
      return false;
    }
  }
}
