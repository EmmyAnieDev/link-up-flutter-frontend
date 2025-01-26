import 'dart:typed_data';

class ChatListModel {
  final int id;
  final String name;
  final String? profilePhoto;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  Uint8List? profilePhotoBytes;

  ChatListModel({
    required this.id,
    required this.name,
    this.profilePhoto,
    required this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    this.profilePhotoBytes,
  });

  factory ChatListModel.fromMap(Map<String, dynamic> map) {
    return ChatListModel(
      id: map['id'],
      name: map['name'] ?? '',
      profilePhoto: map['image'],
      lastMessage: map['last_message'] ?? '',
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'])
          : null,
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  // Method to set profile photo bytes
  void setProfilePhotoBytes(Uint8List? bytes) {
    profilePhotoBytes = bytes;
  }
}
