class Message {
  final String content;
  final int? senderId;
  final DateTime timestamp;
  final bool isMe;
  String status;
  final bool sent;
  final bool delivered;
  final bool read;

  Message({
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
    this.status = 'sending',
    this.sent = false,
    this.delivered = false,
    this.read = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    // Determine status based on message state
    String status = 'sending';
    if (json['sent'] == true) {
      status = 'sent';
    }
    if (json['delivered'] == true) {
      status = 'received';
    }
    if (json['read'] == true) {
      status = 'read';
    }

    return Message(
      content: json['content'] ?? json['message'] ?? '',
      senderId: json['sender_id'] as int?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.parse(json['created_at'] ?? json['sent_at']),
      isMe: json['sender_id'] == currentUserId,
      status: status,
      sent: json['sent'] ?? false,
      delivered: json['delivered'] ?? false,
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'message': content,
      'sender_id': senderId,
      'timestamp': timestamp.toIso8601String(),
      'created_at': timestamp.toIso8601String(),
      'sent_at': timestamp.toIso8601String(),
      'isMe': isMe,
      'status': status,
      'sent': sent,
      'delivered': delivered,
      'read': read,
    };
  }
}
