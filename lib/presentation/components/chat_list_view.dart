import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_list_model.dart';
import '../../data/provider/user_provider.dart';
import '../screens/chat/chat_screen.dart';

class ChatListView extends ConsumerWidget {
  final List<ChatListModel> chatList;

  const ChatListView({super.key, required this.chatList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final up = ref.read(userProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 15, right: 8, left: 8),
      child: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return Column(
            children: [
              InkWell(
                onTap: () {
                  up.selectUser(chat);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(user: chat),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      radius: 25,
                      child: ClipOval(
                          child: CachedNetworkImage(
                              imageUrl:
                                  "http://127.0.0.1:8000${chat.profilePhoto}" ??
                                      '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.grey,
                                  ))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.name,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            chat.lastMessage,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          '${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Color(0xFF626FFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (chat.unreadCount > 0)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF626FFF),
                            ),
                            child: Center(
                              child: Text(
                                '${chat.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          );
        },
      ),
    );
  }
}
