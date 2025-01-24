import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:link_up/data/repositories/auth_repo.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/provider/chat_provider.dart';

class PusherWebSocket {
  final WidgetRef ref;
  late WebSocketChannel channel;

  PusherWebSocket(this.ref);

  void connect() {
    final url =
        'wss://ws-${'mt1'}.pusher.com/app/3ab8844f09ecab0af889?protocol=7&client=Flutter&version=1.0&flash=false';

    channel = WebSocketChannel.connect(Uri.parse(url));

    channel.stream.listen((message) {
      final data = jsonDecode(message);
      print('Received: $data');
      if (data['event'] == 'pusher:connection_established') {
        _subscribeToChannel(data['data']);
      } else {
        _handleEvent(data);
      }
    });
  }

  void _subscribeToChannel(String connectionData) async {
    print('Subscribing to channel...');
    final socketId = jsonDecode(connectionData)['socket_id'];
    final currentUserId = ref.read(authProvider).currentUser?.id;
    final token = await AuthRepository.retrieveToken();

    if (currentUserId == null || token == null) {
      print('Error: No user is currently logged in.');
      return;
    }

    // Ensure channel name starts with 'private-'
    final channelName = 'private-chat.$currentUserId';

    print('Attempting Channel Auth:');
    print('Socket ID: $socketId');
    print('Channel Name: $channelName');
    print('User ID: $currentUserId');
    print('Token: ${token.substring(0, 10)}...');

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/broadcasting/auth'),
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

  void _handleEvent(Map<String, dynamic> eventData) {
    if (eventData['event'] == 'chat-event') {
      print('New Chat Message: ${eventData['data']}');

      try {
        // Parse the data field to a map
        final messageData =
            jsonDecode(eventData['data']) as Map<String, dynamic>;

        // Notify ChatController
        ref.read(chatProvider).handleNewMessage(messageData);
      } catch (e) {
        print('Error parsing chat-event data: $e');
      }
    }
  }

  void disconnect() {
    channel.sink.close();
  }
}
