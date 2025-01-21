import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provider/profile_image_provider.dart';

class ProfileImageWidget extends ConsumerWidget {
  const ProfileImageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pip = ref.watch(profileImageProvider);

    if (pip.isUploading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (pip.imageBytes == null) {
      return const Icon(
        Icons.person, // Fallback icon
        size: 50,
      );
    }

    return Image.memory(
      pip.imageBytes!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error displaying image: $error');
        return const Icon(
          Icons.broken_image,
          color: Colors.red,
          size: 50,
        );
      },
    );
  }
}
