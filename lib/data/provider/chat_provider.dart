import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:link_up/data/repositories/auth_repo.dart';

import '../repositories/chat_repo.dart';

final chatProvider = ChangeNotifierProvider<ChatController>((ref) {
  return ChatController(ref);
});

class Message {
  final String content;
  final int? senderId; // Made nullable
  final DateTime timestamp;
  final bool isMe;

  Message({
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatController extends ChangeNotifier {
  Ref ref;
  final List<Message> messages = [];
  bool isConnected = false;
  String connectionStatus = 'Disconnected';
  bool isSending = false;
  bool isFetching = false;

  ChatController(this.ref);

  Future<void> fetchMessages(String otherUserId) async {
    final currentUserId = ref.watch(authProvider).currentUser?.id;
    final token = await AuthRepository.retrieveToken();

    if (token == null) {
      print('Token not found');
      return;
    }

    isFetching = true;
    notifyListeners();

    try {
      final fetchedMessages =
          await ChatRepository.fetchMessages(otherUserId, token);

      messages.clear();
      messages.addAll(fetchedMessages.map((data) {
        return Message(
          content: data['message'] ?? '',
          senderId: data['sender_id'] as int?,
          timestamp: DateTime.parse(data['created_at'] as String),
          isMe: data['sender_id'] == currentUserId,
        );
      }).toList());

      notifyListeners();
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  void handleNewMessage(Map<String, dynamic> data) {
    try {
      print('New message received: ${data['message']}');
      final currentUserId = ref.watch(authProvider).currentUser?.id;
      final senderId = data['senderId'] as int?;

      final message = Message(
        content: data['message'] ?? '',
        senderId: senderId,
        timestamp: DateTime.now(),
        isMe: senderId == currentUserId,
      );

      messages.add(message);
      notifyListeners();
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  Future<bool> sendMessage(String content, String recipientId) async {
    final currentUser = ref.watch(authProvider).currentUser;
    final token = await AuthRepository.retrieveToken();
    if (token == null) return false;

    isSending = true;
    notifyListeners();

    try {
      final success =
          await ChatRepository.sendMessage(content, recipientId, token);

      print(success);

      print('Message retreived succesful');

      if (success) {
        // Only add message to local list if API call was successful
        print('Message was successful');
        final message = Message(
          content: content,
          senderId: currentUser?.id,
          timestamp: DateTime.now(),
          isMe: true,
        );
        messages.add(message);
        print('Message added to list');
        notifyListeners();
      }

      return success;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
