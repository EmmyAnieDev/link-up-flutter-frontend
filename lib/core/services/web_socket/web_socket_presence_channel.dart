import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../app/config/api_config.dart';
import '../../../app/config/web_socket_config.dart';
import '../../../data/provider/user_provider.dart';
import '../../../data/repositories/auth_repo.dart';

class WebSocketPresenceChannelService {
  final Ref ref;
  late WebSocketChannel channel;

  WebSocketPresenceChannelService(this.ref);

  void connect() {
    final url = WebSocketConfig.webSocketPusherURL;

    channel = WebSocketChannel.connect(Uri.parse(url));

    channel.stream.listen((message) {
      final data = jsonDecode(message);

      if (data['event'] == 'pusher:connection_established') {
        _subscribeToPresenceChannel(data['data']);
      } else if (data['event'] == 'pusher_internal:subscription_succeeded') {
        final presenceData = jsonDecode(data['data'])['presence']['hash'];
        final onlineUsers =
            presenceData.values.toList(); // Extract online users
        _handleSubscriptionSucceeded(onlineUsers);
      } else if (data['event'] == 'pusher_internal:member_added') {
        final userInfo = jsonDecode(data['data'])['user_info'];
        final userId = jsonDecode(data['data'])['user_id'];
        _handleMemberAdded(userId, userInfo);
      } else if (data['event'] == 'pusher_internal:member_removed') {
        final userId = jsonDecode(data['data'])['user_id'];
        _handleMemberRemoved(userId);
      }
    });
  }

  void _subscribeToPresenceChannel(String connectionData) async {
    final socketId = jsonDecode(connectionData)['socket_id'];
    final token = await AuthRepository.retrieveToken();

    if (token == null) return;

    final response = await http.post(
      Uri.parse('${Api.appURL}/broadcasting/auth'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'socket_id': socketId,
        'channel_name': 'presence-online',
      }),
    );

    if (response.statusCode == 200) {
      final authData = jsonDecode(response.body);

      final subscription = {
        'event': 'pusher:subscribe',
        'data': {
          'channel': 'presence-online',
          'auth': authData['auth'],
          'channel_data': authData['channel_data'],
        },
      };

      channel.sink.add(jsonEncode(subscription));
    } else {
      print('Presence channel subscription failed: ${response.body}');
    }
  }

  void _handleSubscriptionSucceeded(List<dynamic> users) {
    for (var user in users) {
      if (user is Map<String, dynamic>) {
        ref.read(userProvider).addOnlineUser(user);
      }
    }
  }

  void _handleMemberAdded(dynamic userId, dynamic userInfo) {
    if (userInfo is Map<String, dynamic>) {
      ref.read(userProvider).addOnlineUser(userInfo);
    } else {
      print('Invalid userInfo format: $userInfo');
    }
  }

  void _handleMemberRemoved(String userId) {
    ref.read(userProvider).removeOnlineUser(userId);
  }

  void disconnect() {
    channel.sink.close();
  }
}
