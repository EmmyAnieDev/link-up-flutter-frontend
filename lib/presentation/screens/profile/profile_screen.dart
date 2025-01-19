import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:link_up/data/provider/user_provider.dart';

import '../../components/profile_photo.dart';
import '../../widgets/profile_text_form_field.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ap = ref.watch(authProvider);
    final up = ref.watch(userProvider);

    final nameController = TextEditingController(text: ap.currentUser?.name);
    final emailController = TextEditingController(text: ap.currentUser?.email);

    print(ap.currentUser?.name);

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF626FFF),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.sansita(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ap.logoutUser(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: Form(
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
                      controller: nameController,
                      label: 'Name',
                      icon: Icons.person_outline,
                    ),
                    ProfileTextFormField(
                      controller: emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: 40,
                      width: 180,
                      child: ElevatedButton(
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          final newEmail = emailController.text.trim();
                          await up.updateUserProfile(
                              context, newName, newEmail);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF626FFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: up.isLoading
                            ? const SpinKitThreeBounce(
                                color: Color(0xFFFFFFFF),
                                size: 18.0,
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
