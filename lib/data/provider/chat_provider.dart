import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:link_up/data/provider/user_provider.dart';
import 'package:link_up/data/repositories/auth_repo.dart';

import '../models/message_model.dart';
import '../repositories/chat_repo.dart';

final chatProvider = ChangeNotifierProvider<ChatController>((ref) {
  return ChatController(ref);
});

class ChatController extends ChangeNotifier {
  Ref ref;
  final List<Message> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isConnected = false;
  String connectionStatus = 'Disconnected';
  bool isSending = false;
  bool isFetching = false;

  ChatController(this.ref);

  Future<void> initializeChat() async {
    final selectedUser = ref.read(userProvider).selectedUser;
    if (selectedUser != null) {
      await fetchMessages(selectedUser.id.toString());
      scrollToBottomInitially();
    }
  }

  void scrollToBottomInitially() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      }
    });
  }

  Future<void> fetchMessages(String otherUserId) async {
    final currentUserId = ref.watch(authProvider).currentUser?.id;
    final token = await AuthRepository.retrieveToken();

    if (token == null || currentUserId == null) return;

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

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final currentUser = ref.read(authProvider).currentUser;
    final selectedUser = ref.read(userProvider).selectedUser;
    final token = await AuthRepository.retrieveToken();

    if (token == null || selectedUser == null) return;

    // Optimistically add the message to the list
    final pendingMessage = Message(
      content: messageController.text.trim(),
      senderId: currentUser?.id,
      timestamp: DateTime.now(),
      isMe: true,
    );

    messages.add(pendingMessage);
    notifyListeners();

    messageController.clear();

    isSending = true;
    notifyListeners();

    try {
      final success = await ChatRepository.sendMessage(
        pendingMessage.content,
        selectedUser.id.toString(),
        token,
      );

      if (success) {
        pendingMessage.status = 'sent';
      } else {
        pendingMessage.status = 'failed';
      }
      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
      messages.remove(pendingMessage);
      notifyListeners();
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
