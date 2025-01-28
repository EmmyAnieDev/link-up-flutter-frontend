import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'web_socket_chat_channel.dart';
import 'web_socket_presence_channel.dart';

final webSocketProvider = Provider<WebSocketManager>((ref) {
  final webSocketManager = WebSocketManager(ref);
  webSocketManager.init();
  return webSocketManager;
});

class WebSocketManager {
  final Ref ref;
  late final WebSocketChatChannelService chatWebSocket;
  late final WebSocketPresenceChannelService presenceWebSocket;

  WebSocketManager(this.ref) {
    chatWebSocket = WebSocketChatChannelService(ref);
    presenceWebSocket = WebSocketPresenceChannelService(ref);
  }

  void init() {
    try {
      chatWebSocket.connect();
      presenceWebSocket.connect();
    } catch (e) {
      print('Error initializing WebSocketManager: $e');
    }
  }

  void dispose() {
    chatWebSocket.disconnect();
    presenceWebSocket.disconnect();
  }
}
