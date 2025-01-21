class ChatListModel {
  final int id;
  final String name;
  final String? profilePhoto;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatListModel({
    required this.id,
    required this.name,
    this.profilePhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ChatListModel.fromMap(Map<String, dynamic> map) {
    return ChatListModel(
      id: map['id'],
      name: map['name'] ?? '',
      profilePhoto: map['image'],
      lastMessage: map['lastMessage'] ?? 'No messages yet',
      lastMessageTime: DateTime.parse(
          map['lastMessageTime'] ?? DateTime.now().toIso8601String()),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }
}
