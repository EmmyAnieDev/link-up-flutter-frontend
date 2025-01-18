import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeCreateAccountText extends StatelessWidget {
  const WelcomeCreateAccountText(
      {super.key, required this.label, required this.subLabel});

  final String label, subLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subLabel,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
