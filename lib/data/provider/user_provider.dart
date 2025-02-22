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

  bool _isUpdateLoading = false;
  bool _isDeleteLoading = false;

  bool get isUpdateLoading => _isUpdateLoading;
  bool get isDeleteLoading => _isDeleteLoading;

  List<ChatListModel> _appUsers = [];
  List<ChatListModel> get appUsers => _appUsers;

  ChatListModel? _selectedUser;
  ChatListModel? get selectedUser => _selectedUser;

  List<Map<String, dynamic>> _onlineUsers = [];
  List<Map<String, dynamic>> get onlineUsers => _onlineUsers;

  UserController(this.ref) {
    getAppUsers();
  }

  /// Add an online user
  void addOnlineUser(Map<String, dynamic> userInfo) {
    if (!_onlineUsers.any((user) => user['id'] == userInfo['id'])) {
      _onlineUsers = [..._onlineUsers, userInfo];
      notifyListeners();
    }
  }

  /// remove online user
  void removeOnlineUser(String userId) {
    _onlineUsers =
        _onlineUsers.where((user) => user['id'].toString() != userId).toList();
    notifyListeners();
  }

  Future<void> selectUser(ChatListModel user) async {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelectedUser() {
    _selectedUser = null;
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
      _isUpdateLoading = true;
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

      final updatedUser = User(name: name, email: email);

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
      _isUpdateLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      _isDeleteLoading = true;
      notifyListeners();

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
    } finally {
      _isDeleteLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAppUsers() async {
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

      // Fetch profile photo bytes for each user
      for (var user in _appUsers) {
        if (user.profilePhoto != null) {
          try {
            final photoBytes = await UserRepository.fetchAppUsersProfilePhoto(
              user.profilePhoto!,
              token,
            );
            user.setProfilePhotoBytes(photoBytes);
          } catch (e) {
            print('Error fetching profile photo for ${user.name}: $e');
          }
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
      _appUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateLastMessage(userId, lastMessage, lastMessageTime) {
    final index = _appUsers.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _appUsers[index] = ChatListModel(
        id: _appUsers[index].id,
        name: _appUsers[index].name,
        profilePhoto: _appUsers[index].profilePhoto,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        unreadCount: _appUsers[index].unreadCount,
        profilePhotoBytes: _appUsers[index].profilePhotoBytes,
      );
      notifyListeners();
    }
  }

  void sortChatList() {
    _appUsers.sort((a, b) {
      final timeA = a.lastMessageTime ?? DateTime(1970, 1, 1);
      final timeB = b.lastMessageTime ?? DateTime(1970, 1, 1);
      return timeB.compareTo(timeA); // Sort in descending order
    });
    notifyListeners();
  }
}
