import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_up/data/provider/user_provider.dart';

import '../../../core/services/pusher_service.dart';
import '../../components/appbar_profile_photo.dart';
import '../../components/chat_list_view.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  late PusherWebSocket _pusherWebSocket;

  @override
  void initState() {
    super.initState();

    // Initialize PusherWebSocket with WidgetRef
    _pusherWebSocket = PusherWebSocket(ref);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _pusherWebSocket.connect();
      } catch (e) {
        print('Error connecting WebSocket: $e');
      }
    });
  }

  @override
  void dispose() {
    _pusherWebSocket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userController = ref.watch(userProvider);
    final users = userController.appUsers;
    final isLoading = userController.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF626FFF),
        title: Text(
          'Chat List',
          style: GoogleFonts.sansita(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        actions: const [
          AppBarProfilePhoto(),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('No users found'))
              : ChatListView(chatList: users),
    );
  }
}
