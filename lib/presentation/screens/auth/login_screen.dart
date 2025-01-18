import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_up/presentation/components/login_textfield_wrapper.dart';

import '../../components/logo_brand.dart';
import '../../components/new_or_have_account_button.dart';
import '../../widgets/background_stack_circles.dart';
import '../../widgets/welcome_create_account_text.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                                label: 'Welcome back',
                                subLabel: 'Sign in to continue',
                              ),
                              const SizedBox(height: 40),
                              LoginTextfieldWrapper(),
                              const Spacer(flex: 1),
                              Center(
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: NewOrHaveAccountButton(
                                  text: 'New to Linkup? ',
                                  buttonText: 'Create Account',
                                  onPress: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                                ),
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
