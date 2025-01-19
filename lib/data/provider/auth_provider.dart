import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/presentation/screens/auth/login_screen.dart';
import 'package:link_up/presentation/screens/chat/chat_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/api_exception.dart';
import '../../core/utils/show_notifier_snack_bar.dart';
import '../../core/utils/validators.dart';
import '../models/user_model.dart';
import '../repositories/auth_repo.dart';

final authProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController();
});

class AuthController extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthController() {
    loadUserFromPreferences();
  }

  Future<void> registerUser(BuildContext context) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final newUser = User(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      final userData = await AuthRepository.registerUser(newUser);
      print('User data from api $userData');

      _currentUser = User.fromJson(userData);
      await saveUserToPreferences(_currentUser!);
      print('Current User Data: $userData');

      await Future.delayed(const Duration(seconds: 3));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      clearController();
    } catch (e) {
      String errorMessage = 'Registration failed: ';
      if (e is ApiException) {
        errorMessage += e.message;
      } else {
        errorMessage += e.toString();
      }

      print(errorMessage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginUser(BuildContext context) async {
    if (_isLoading) return;

    try {
      final email = emailController.text;
      final password = passwordController.text;

      final emailError = validateEmail(email);
      final passwordError = validatePassword(password);

      if (emailError != null || passwordError != null) {
        ShowNotifierSnackBar.showSnackBar(
          context,
          emailError ?? passwordError!,
          const Color(0xFFFFFFFF),
          const Color(0xFF626FFF),
        );
        return; // Stop further execution if validation fails
      }

      _isLoading = true;
      notifyListeners();

      final loggedInUser = await AuthRepository.loginUser(email, password);

      _currentUser = loggedInUser;
      await saveUserToPreferences(_currentUser!);
      print('Logged-in User Data: ${_currentUser?.toJson()}');

      await Future.delayed(const Duration(seconds: 3));

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ChatListScreen(),
        ),
      );

      ShowNotifierSnackBar.showSnackBar(
        context,
        'Login successful!',
        const Color(0xFFFFFFFF),
        const Color(0xFF626FFF),
      );

      clearController();
    } catch (e) {
      ShowNotifierSnackBar.showSnackBar(
        context,
        'Invalid Credentials!',
        const Color(0xFFFFFFFF),
        const Color(0xFF626FFF),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    final token = await AuthRepository.retrieveToken();

    if (token == null) {
      ShowNotifierSnackBar.showSnackBar(
        context,
        'Unauthenticated',
        const Color(0xFF626FFF),
        const Color(0xFFFFFFFF),
      );
      return;
    }

    try {
      await AuthRepository.logoutUser(token);

      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );

      ShowNotifierSnackBar.showSnackBar(
        context,
        'Logout successful!',
        const Color(0xFFFFFFFF),
        const Color(0xFF626FFF),
      );
    } catch (e) {
      print('Logout failed: ${e.toString()}');
      ShowNotifierSnackBar.showSnackBar(
        context,
        'Logout failed!',
        const Color(0xFF626FFF),
        const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> saveUserToPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user.toJson()));
  }

  Future<void> loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('currentUser');
    print('User data from shared Preferences $userData');
    if (userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  clearController() {
    emailController.clear();
    nameController.clear();
    passwordController.clear();
  }
}
