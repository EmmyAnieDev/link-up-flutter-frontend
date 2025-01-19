import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileButton extends StatelessWidget {
  final Function(File) onImageSelected;

  const EditProfileButton({
    super.key,
    required this.onImageSelected,
  });

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        debugPrint('Selected Image Path: ${image.path}');
        onImageSelected(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          pickImage(ImageSource.gallery);
        },
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
