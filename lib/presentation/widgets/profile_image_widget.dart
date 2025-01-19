import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/data/provider/auth_provider.dart';

import '../../app/config/api_config.dart';
import '../../data/provider/profile_image_provider.dart';

class ProfileImageWidget extends ConsumerWidget {
  const ProfileImageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pip = ref.watch(profileImageProvider);
    final ap = ref.watch(authProvider);
    final imageUrl = ap.currentUser?.profilePhoto;
    const String baseUrl = Api.storageUrl;
    final fullImageUrl = '$baseUrl$imageUrl';

    if (pip.isUploading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        'images/profile.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Image.network(
      fullImageUrl, // just URL string, no 'imageUrl:' needed
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      headers: {
        // Add headers if needed for authentication
        'Access-Control-Allow-Origin': '*',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: Color(0xFF626FFF),
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print("Error loading image: $error");
        return const Icon(
          Icons.broken_image,
          color: Colors.red,
          size: 50,
        );
      },
    );
  }
}
