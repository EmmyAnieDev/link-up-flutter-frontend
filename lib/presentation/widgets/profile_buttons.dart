import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileButtons extends ConsumerWidget {
  const ProfileButtons({
    super.key,
    required this.color,
    required this.label,
    required this.onPress,
    this.isLoading = false,
  });

  final Color color;
  final String label;
  final VoidCallback onPress;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 180,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 17),
        ),
        child: isLoading
            ? const SpinKitThreeBounce(
                color: Color(0xFFFFFFFF),
                size: 18.0,
              )
            : Text(
                label,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
