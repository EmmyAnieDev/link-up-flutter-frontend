import 'package:flutter/material.dart';

import '../screens/chat/chat_list_screen.dart';
import '../widgets/authentication_button.dart';
import '../widgets/custom_text_form_field.dart';

class LoginTextfieldWrapper extends StatelessWidget {
  const LoginTextfieldWrapper({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextFormField(
            hintText: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            hintText: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            showVisibilityToggle: true,
          ),
          const SizedBox(height: 24),
          AuthenticationButton(
            label: 'Sign In',
            onPress: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
