import 'package:flutter/material.dart';

import 'received_message_bubble.dart';
import 'send_message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ReceivedMessageBubble(
          message: 'People are waiting for you downstairs, please come now',
          time: '17:24',
        ),
        SentMessageBubble(
          message: 'Okay i am coming. Thanks!',
          time: '17:24',
        ),
      ],
    );
  }
}
