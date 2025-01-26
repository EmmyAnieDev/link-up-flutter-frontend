import 'package:flutter/material.dart';

class UnreadCountsIndicator extends StatelessWidget {
  const UnreadCountsIndicator({
    super.key,
    required this.unreadCount,
  });

  final dynamic unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF626FFF),
      ),
      child: Center(
        child: Text(
          '$unreadCount',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
