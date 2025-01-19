import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:link_up/data/repositories/auth_repo.dart';

import '../screens/auth/login_screen.dart';
import '../screens/chat/chat_list_screen.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  Future<void> _checkUserLoginStatus() async {
    final token = await AuthRepository.retrieveToken();

    print(token);

    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: SpinKitThreeBounce(
            color: Color(0xFF626FFF),
            size: 18.0,
          ),
        ),
      );
    }

    return _isLoggedIn ? const ChatListScreen() : const LoginScreen();
  }
}
