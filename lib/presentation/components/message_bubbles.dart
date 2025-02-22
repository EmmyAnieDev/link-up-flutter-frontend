import 'package:flutter/material.dart';

import '../../core/utils/date_formatter.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formattedTime = formatTimestamp(message.timestamp);

    final isMe = message.isMe;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final backgroundColor = isMe ? const Color(0xFF626FFF) : Colors.white;
    final textColor = isMe ? Colors.white : Colors.grey.shade800;
    final borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(15),
      bottomRight: Radius.circular(15),
      topLeft: isMe ? Radius.circular(15) : Radius.zero,
      topRight: isMe ? Radius.zero : Radius.circular(15),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.85,
          minWidth: screenWidth * 0.25,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: isMe
                ? null
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6.0,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: Padding(
            padding: isMe
                ? const EdgeInsets.only(left: 8)
                : const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                    Icon(Icons.done),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
