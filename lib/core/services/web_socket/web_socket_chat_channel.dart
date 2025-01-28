import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:link_up/data/repositories/auth_repo.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../app/config/api_config.dart';
import '../../../app/config/web_socket_config.dart';
import '../../../data/provider/chat_provider.dart';
import '../../../data/provider/user_provider.dart';

class WebSocketChatChannelService {
  final Ref ref;
  late WebSocketChannel channel;

  WebSocketChatChannelService(this.ref);

  void connect() {
    final url = WebSocketConfig.webSocketPusherURL;

    channel = WebSocketChannel.connect(Uri.parse(url));

    channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['event'] == 'pusher:connection_established') {
        _subscribeToChannel(data['data']);
      } else {
        _handleEvent(data);
      }
    });
  }

  void _subscribeToChannel(String connectionData) async {
    final socketId = jsonDecode(connectionData)['socket_id'];
    final currentUserId = ref.read(authProvider).currentUser?.id;
    final token = await AuthRepository.retrieveToken();

    if (currentUserId == null || token == null) {
      return;
    }

    final channelName = 'private-chat.$currentUserId';

    final response = await http.post(
      Uri.parse('${Api.appURL}/broadcasting/auth'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'socket_id': socketId,
        'channel_name': channelName,
      }),
    );

    if (response.statusCode == 200) {
      final authData = jsonDecode(response.body);

      final subscription = {
        'event': 'pusher:subscribe',
        'data': {
          'channel': channelName,
          'auth': authData['auth'],
        },
      };
      channel.sink.add(jsonEncode(subscription));
    } else {
      print('Subscription failed: ${response.body}');
    }
  }

  // Handle event from the backend.
  void _handleEvent(Map<String, dynamic> eventData) {
    if (eventData['event'] == 'chat-event') {
      try {
        final messageData =
            jsonDecode(eventData['data']) as Map<String, dynamic>;

        // Update the chat list with the new last message and time
        ref.read(userProvider).updateLastMessage(
              messageData['senderId'],
              messageData['last_message'],
              DateTime.parse(messageData['last_message_time']),
            );

        // Resort chat list after receiving a new message
        ref.read(userProvider).sortChatList();

        // Handle new message
        ref.read(chatProvider).handleNewMessage(messageData);

        // Trigger fetching of unread counts
        ref.read(chatProvider).fetchUnreadCounts();
      } catch (e) {
        print('Error parsing chat-event data: $e');
      }
    }
  }

  void disconnect() {
    channel.sink.close();
  }
}
