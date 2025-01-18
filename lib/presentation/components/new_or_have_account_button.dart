import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewOrHaveAccountButton extends StatelessWidget {
  const NewOrHaveAccountButton({
    super.key,
    required this.text,
    required this.buttonText,
    required this.onPress,
  });

  final String text, buttonText;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: onPress,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            buttonText,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
