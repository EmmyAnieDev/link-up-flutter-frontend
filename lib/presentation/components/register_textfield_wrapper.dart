import 'package:flutter/material.dart';
import 'package:link_up/presentation/widgets/authentication_button.dart';

import '../screens/chat/chat_list_screen.dart';
import '../widgets/custom_text_form_field.dart';

class RegisterTextfieldWrapper extends StatelessWidget {
  const RegisterTextfieldWrapper({super.key});

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
            hintText: 'Username',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
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
            showVisibilityToggle: false,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            hintText: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            showVisibilityToggle: false,
          ),
          const SizedBox(height: 24),
          AuthenticationButton(
            label: 'Sign Up',
            onPress: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
