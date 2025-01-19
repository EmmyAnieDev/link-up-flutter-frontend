import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provider/profile_image_provider.dart';
import '../widgets/profile_image_widget.dart';
import 'image_preview_dialog.dart';

class ProfilePhoto extends ConsumerWidget {
  const ProfilePhoto({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pip = ref.watch(profileImageProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: ClipOval(
              child: const ProfileImageWidget(),
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          child: InkWell(
            onTap: () async {
              await pip.pickImage(context);
              if (pip.imageBytes != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ImagePreviewDialog(
                      imageBytes: pip.imageBytes!,
                      onUpload: () {
                        pip.uploadProfileImage();
                      },
                    );
                  },
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ),
      ],
    );
  }
}
