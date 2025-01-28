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
  List<Map<String, dynamic>> unreadCounts = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;
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
        String status = 'sending';
        if (data['sent'] == true) {
          status = 'sent';
        }
        if (data['delivered'] == true) {
          status = 'received';
        }
        if (data['read'] == true) {
          status = 'read';
        }

        return Message(
          content: data['message'] ?? '',
          senderId: data['sender_id'] as int?,
          timestamp: DateTime.parse(data['created_at'] as String),
          isMe: data['sender_id'] == currentUserId,
          status: status,
          sent: data['sent'] ?? false,
          delivered: data['delivered'] ?? false,
          read: data['read'] ?? false,
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

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final currentUser = ref.read(authProvider).currentUser;
    final selectedUser = ref.read(userProvider).selectedUser;
    final token = await AuthRepository.retrieveToken();

    if (token == null || selectedUser == null) return;

    // Optimistically add the message to the sender message list
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
        // Find the index of the optimistically added message
        final index = messages.indexOf(pendingMessage);

        if (index != -1) {
          // Replace the pending message with the sent message
          messages[index] = Message(
            content: pendingMessage.content,
            senderId: currentUser?.id,
            timestamp: DateTime.now(),
            isMe: true,
            status: 'sent',
          );
        }

        // Update last_message and last_message_time manually for sender
        ref.read(userProvider).updateLastMessage(
              selectedUser.id,
              pendingMessage.content,
              DateTime.now(),
            );

        // Resort chat list after updating last message
        ref.read(userProvider).sortChatList();

        // remove unread count for the current selected user chat
        await removeUnreadMessageCounts(selectedUser.id.toString());
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

  // Handle message from web socket service class for real time.
  void handleNewMessage(Map<String, dynamic> data) {
    try {
      final currentUserId = ref.watch(authProvider).currentUser?.id;
      final selectedUser = ref.read(userProvider).selectedUser;

      final senderId = data['senderId'] as int?;
      final messageContent = data['message'] ?? '';

      final isCurrentChat =
          (selectedUser != null && selectedUser.id == senderId);

      // Check if the message already exists
      final isDuplicate = messages.any((message) =>
          message.content == messageContent &&
          message.senderId == senderId &&
          message.timestamp.difference(DateTime.now()).inSeconds.abs() < 2);

      if (isDuplicate) return;

      // Create new message
      final newMessage = Message(
        content: messageContent,
        senderId: senderId,
        timestamp: DateTime.now(),
        isMe: senderId == currentUserId,
      );

      messages.add(newMessage);

      // If the message is from the current chat, remove current selected user chat
      if (isCurrentChat) {
        removeUnreadMessageCounts(senderId.toString());
      }

      notifyListeners();
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  Future<void> fetchUnreadCounts() async {
    final token = await AuthRepository.retrieveToken();

    if (token == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedUnreadCounts = await ChatRepository.fetchUnreadCounts(token);
      unreadCounts = fetchedUnreadCounts;
      notifyListeners();
    } catch (error) {
      print('Error fetching unread counts: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeUnreadMessageCounts(String senderId) async {
    final token = await AuthRepository.retrieveToken();

    if (token == null) return;

    try {
      final response =
          await ChatRepository.removeUnreadMessageCounts(senderId, token);

      if (response['success']) {
        // Optionally refresh unread counts
        await fetchUnreadCounts();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
