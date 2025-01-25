import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:link_up/data/provider/user_provider.dart';

import '../widgets/profile_buttons.dart';
import '../widgets/profile_text_form_field.dart';
import 'profile_photo.dart';

class ProfileBody extends ConsumerWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final ap = ref.watch(authProvider);
    final up = ref.watch(userProvider);

    // Preset the controllers with current user data if not already set
    ap.nameController.text = ap.currentUser?.name ?? ap.nameController.text;
    ap.emailController.text = ap.currentUser?.email ?? ap.emailController.text;

    return Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFF626FFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const ProfilePhoto(),
                  const SizedBox(height: 20),
                  ProfileTextFormField(
                    controller: ap.nameController,
                    label: 'Name',
                    icon: Icons.person_outline,
                  ),
                  ProfileTextFormField(
                    controller: ap.emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  ProfileButtons(
                    color: const Color(0xFF626FFF),
                    label: 'Save Changes',
                    isLoading: up.isUpdateLoading,
                    onPress: () async {
                      final newName = ap.nameController.text.trim();
                      final newEmail = ap.emailController.text.trim();
                      await up.updateUserProfile(context, newName, newEmail);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ProfileButtons(
            color: Colors.redAccent,
            label: 'Delete Account',
            isLoading: up.isDeleteLoading,
            onPress: () async => up.deleteUser(context),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        ],
      ),
    );
  }
}
