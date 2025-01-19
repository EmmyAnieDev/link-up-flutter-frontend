import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowNotifierSnackBar {
  static void showSnackBar(
      BuildContext context, String label, Color color, Color labelColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: labelColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
