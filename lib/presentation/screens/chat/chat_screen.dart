import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider).initializeChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cp = ref.watch(chatProvider);
    final crp = ref.read(chatProvider);
    final up = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF626FFF),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(userProvider).clearSelectedUser();
          },
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
              child: cp.isFetching
                  ? const Center(
                      child: SpinKitThreeBounce(
                      color: Color(0xFF626FFF),
                      size: 18.0,
                    ))
                  : ListView.builder(
                      controller: crp.scrollController,
                      reverse: true,
                      itemCount: cp.messages.length,
                      itemBuilder: (context, index) {
                        final message =
                            cp.messages[cp.messages.length - 1 - index];
                        return MessageBubble(message: message);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: crp.messageController,
                        onSubmitted: (_) => crp.sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
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
                      onPressed: crp.sendMessage,
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
