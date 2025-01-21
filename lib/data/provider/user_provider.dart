import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/data/models/chat_list_model.dart';
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/show_notifier_snack_bar.dart';
import '../../core/utils/validators.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../models/user_model.dart';
import '../repositories/auth_repo.dart';
import '../repositories/user_repo.dart';

final userProvider = ChangeNotifierProvider<UserController>((ref) {
  return UserController(ref);
});

class UserController extends ChangeNotifier {
  final Ref ref;
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ChatListModel> _appUsers = [];
  List<ChatListModel> get appUsers => _appUsers;

  ChatListModel? _selectedUser;
  ChatListModel? get selectedUser => _selectedUser;

  UserController(this.ref) {
    getAppUsers();
  }

  Future<void> selectUser(ChatListModel user) async {
    _selectedUser = user;
    notifyListeners();
  }

  Future<void> updateUserProfile(BuildContext context, name, email) async {
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
      _isLoading = true;
      notifyListeners();

      final nameError = validateName(name);
      final emailError = validateEmail(email);

      if (nameError != null || emailError != null) {
        ShowNotifierSnackBar.showSnackBar(
          context,
          nameError ?? emailError!,
          const Color(0xFF626FFF),
          const Color(0xFFFFFFFF),
        );
        return;
      }

      final updatedUser = User(
        name: name,
        email: email,
      );

      final updatedUserData =
          await UserRepository.updateUser(updatedUser, token);

      _currentUser = User.fromJson(updatedUserData);
      await ref.read(authProvider).saveUserToPreferences(_currentUser!);

      await Future.delayed(const Duration(seconds: 3));

      await ref.read(authProvider).loadUserFromPreferences();

      ShowNotifierSnackBar.showSnackBar(
        context,
        'Profile updated successfully!',
        const Color(0xFF626FFF),
        const Color(0xFFFFFFFF),
      );
    } catch (e) {
      ShowNotifierSnackBar.showSnackBar(
        context,
        'Update failed: Email Belongs To existing User',
        const Color(0xFF626FFF),
        const Color(0xFFFFFFFF),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> debugPrintCurrentPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('currentUser');
    print('Current data in preferences: $userData');
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
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

      await UserRepository.deleteUser(token);

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
        'Account deleted!',
        const Color(0xFFFFFFFF),
        const Color(0xFF626FFF),
      );
    } catch (e) {
      print('Account deleted failed: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deleted failed: ${e.toString()}')),
      );
    }
  }

  Future<void> getAppUsers() async {
    print('Fetching users...');
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthRepository.retrieveToken();

      if (token == null) {
        print('No token found.');
        _appUsers = [];
        return;
      }

      _appUsers = await UserRepository.fetchAppUsers(token);
      print('Fetched users: $_appUsers');
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
      _appUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Loading completed.');
    }
  }
}
