import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImagePreviewDialog extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onUpload;

  const ImagePreviewDialog({
    super.key,
    required this.imageBytes,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Upload Preview',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF626FFF),
        ),
      ),
      content: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        height: 200,
        width: 200,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'cancel',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onUpload();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF626FFF),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Upload',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
