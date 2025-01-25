import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/app/router/go_router.dart';
import 'package:link_up/presentation/components/logo_brand.dart';
import 'package:link_up/presentation/components/new_or_have_account_button.dart';
import 'package:link_up/presentation/components/register_textfield_wrapper.dart';
import 'package:link_up/presentation/widgets/background_stack_circles.dart';
import 'package:link_up/presentation/widgets/welcome_create_account_text.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            BackgroundTopRightStackCircle(),
            BackgroundBottomLeftStackCircle(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      LogoBrand(),
                      const SizedBox(height: 50),
                      WelcomeCreateAccountText(
                        label: 'Create Account',
                        subLabel: 'Join and start connecting!',
                      ),
                      const SizedBox(height: 20),
                      RegisterTextfieldWrapper(),
                      const SizedBox(height: 70),
                      Center(
                        child: NewOrHaveAccountButton(
                          text: 'Already have an account? ',
                          buttonText: 'Login here',
                          onPress: () => context.go(AppRouter.loginPath),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
