class Message {
  final String content;
  final int? senderId;
  final DateTime timestamp;
  final bool isMe;
  String status;

  Message({
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
    this.status = 'pending',
  });

  // Factory constructor for creating a Message object from JSON
  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    return Message(
      content: json['content'] ?? '',
      senderId: json['sender_id'] as int?,
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['sender_id'] == currentUserId,
      status: json['status'] ?? 'sent',
    );
  }

  // Method to convert a Message object to JSON
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender_id': senderId,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe, // Optional if needed for local state
      'status': status
    };
  }
}
