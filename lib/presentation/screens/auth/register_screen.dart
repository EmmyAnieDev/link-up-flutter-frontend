import 'package:flutter/material.dart';
import 'package:link_up/presentation/components/logo_brand.dart';
import 'package:link_up/presentation/components/new_or_have_account_button.dart';
import 'package:link_up/presentation/screens/auth/login_screen.dart';

import '../../components/register_textfield_wrapper.dart';
import '../../widgets/background_stack_circles.dart';
import '../../widgets/welcome_create_account_text.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7B86FF),
              const Color(0xFF626FFF),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                BackgroundTopRightStackCircle(),
                BackgroundBottomLeftStackCircle(),
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              LogoBrand(),
                              const Spacer(flex: 1),
                              WelcomeCreateAccountText(
                                label: 'Create Account',
                                subLabel: 'Join and start connecting!',
                              ),
                              const SizedBox(height: 40),
                              RegisterTextfieldWrapper(),
                              const Spacer(flex: 1),
                              NewOrHaveAccountButton(
                                text: 'Already have an account? ',
                                buttonText: 'Login here',
                                onPress: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
