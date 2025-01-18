import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoBrand extends StatelessWidget {
  const LogoBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 30,
            color: Color(0xFF626FFF),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'LinkUp',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
