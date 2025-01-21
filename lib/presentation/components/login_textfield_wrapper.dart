import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:link_up/data/provider/auth_provider.dart';

import '../../data/provider/user_provider.dart';
import '../widgets/authentication_button.dart';
import '../widgets/custom_text_form_field.dart';

class LoginTextfieldWrapper extends ConsumerWidget {
  const LoginTextfieldWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ap = ref.watch(authProvider);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextFormField(
              hintText: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: ap.emailController,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              hintText: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              showVisibilityToggle: true,
              controller: ap.passwordController,
            ),
            const SizedBox(height: 24),
            AuthenticationButton(
              label: ap.isLoading
                  ? const SpinKitThreeBounce(
                      color: Color(0xFF626FFF),
                      size: 18.0,
                    )
                  : const Text('Sign In'),
              onPress: () {
                ap.loginUser(context);
                ref.watch(userProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}
