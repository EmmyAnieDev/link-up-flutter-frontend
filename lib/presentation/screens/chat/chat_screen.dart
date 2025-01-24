import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_up/presentation/components/message_bubbles.dart';

import '../../../data/provider/chat_provider.dart';
import '../../../data/provider/user_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Fetch messages and ensure initial scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedUser = ref.read(userProvider).selectedUser;
      if (selectedUser != null) {
        ref
            .read(chatProvider)
            .fetchMessages(selectedUser.id.toString())
            .then((_) {
          _scrollToBottomInitially();
        });
      }
    });
  }

  void _scrollToBottomInitially() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final selectedUser = ref.read(userProvider).selectedUser;
    if (selectedUser != null) {
      ref.read(chatProvider).sendMessage(
            _messageController.text.trim(),
            selectedUser.id.toString(),
          );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final up = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF626FFF),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          up.selectedUser?.name ?? '',
          style: GoogleFonts.sansita(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 25,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: chatState.isFetching
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatState
                            .messages[chatState.messages.length - 1 - index];
                        return MessageBubble(message: message);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF626FFF),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
