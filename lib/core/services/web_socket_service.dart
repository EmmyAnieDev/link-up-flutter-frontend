import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:link_up/data/repositories/auth_repo.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../app/config/api_config.dart';
import '../../app/config/web_socket_config.dart';
import '../../data/provider/chat_provider.dart';

class WebSocketService {
  final WidgetRef ref;
  late WebSocketChannel channel;

  WebSocketService(this.ref);

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

  void _handleEvent(Map<String, dynamic> eventData) {
    if (eventData['event'] == 'chat-event') {
      try {
        final messageData =
            jsonDecode(eventData['data']) as Map<String, dynamic>;

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
