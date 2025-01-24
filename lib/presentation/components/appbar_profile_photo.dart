import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/go_router.dart';
import '../../data/provider/profile_image_provider.dart';

class AppBarProfilePhoto extends ConsumerWidget {
  const AppBarProfilePhoto({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pip = ref.watch(profileImageProvider);

    return InkWell(
      onTap: () => context.go(AppRouter.profilePath),
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.transparent,
              backgroundImage:
                  pip.imageBytes != null ? MemoryImage(pip.imageBytes!) : null,
              child: pip.imageBytes == null
                  ? const Icon(
                      Icons.person,
                      size: 20,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
