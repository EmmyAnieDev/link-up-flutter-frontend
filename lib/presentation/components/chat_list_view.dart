import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/data/models/chat_list_model.dart';
import 'package:link_up/data/provider/chat_provider.dart';
import 'package:link_up/data/provider/user_provider.dart';

import '../../app/router/go_router.dart';
import '../../core/utils/date_formatter.dart';
import '../widgets/unread_counts_indicator.dart';

class ChatListView extends ConsumerWidget {
  final List<ChatListModel> chatList;

  const ChatListView({super.key, required this.chatList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cp = ref.watch(chatProvider);
    final crp = ref.read(chatProvider);
    final onlineUsers = ref.watch(userProvider).onlineUsers;

    print('Online Users in UI: $onlineUsers'); // Debug online users list

    return Padding(
      padding: const EdgeInsets.only(top: 15, right: 8, left: 8),
      child: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          print('Chat ID: ${chat.id}'); // Debug each chat ID

          // Check if the user is online
          final isOnline = onlineUsers
              .any((user) => user['id'].toString() == chat.id.toString());

          final unreadCount = cp.unreadCounts.firstWhere(
            (element) => element['sender_id'] == chat.id,
            orElse: () => {'unread_count': 0},
          )['unread_count'];

          final formattedTime = chat.lastMessageTime != null
              ? formatTimestamp(chat.lastMessageTime!)
              : '';

          return Column(
            children: [
              InkWell(
                onTap: () {
                  ref.read(userProvider).selectUser(chat);
                  context.push(AppRouter.chatPath);
                  crp.removeUnreadMessageCounts(chat.id.toString());
                },
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 23,
                          child: ClipOval(
                            child: chat.profilePhotoBytes != null
                                ? Image.memory(
                                    chat.profilePhotoBytes!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 28,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                            chat.lastMessage ?? '',
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
                        if (unreadCount > 0)
                          UnreadCountsIndicator(unreadCount: unreadCount),
                        const SizedBox(height: 3),
                        if (chat.lastMessageTime != null)
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              color: Color(0xFF626FFF),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
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
