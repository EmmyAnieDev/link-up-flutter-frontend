import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/data/provider/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../repositories/auth_repo.dart';
import '../repositories/profile_image_repo.dart';

final profileImageProvider =
    ChangeNotifierProvider<ProfileImageController>((ref) {
  return ProfileImageController(ref);
});

class ProfileImageController extends ChangeNotifier {
  final Ref _ref;
  Uint8List? _imageBytes;
  String? _imageUrl;
  String? _imageFileName;
  bool _isUploading = false;

  Uint8List? get imageBytes => _imageBytes;
  String? get imageUrl => _imageUrl;
  String? get imageFileName => _imageFileName;
  bool get isUploading => _isUploading;

  ProfileImageController(this._ref) {
    _initializeProfileImage();
  }

  Future<void> _initializeProfileImage() async {
    // Wait for the AppUser to be loaded
    await Future.doWhile(() async {
      final ap = _ref.read(authProvider);
      if (ap.currentUser != null) {
        await _loadProfileImage();
        return false; // Stop waiting
      }
      await Future.delayed(const Duration(milliseconds: 100));
      return true; // Continue waiting
    });
  }

  Future<void> uploadProfileImage() async {
    final token = await AuthRepository.retrieveToken();

    final ap = _ref.read(authProvider);

    if (_imageBytes == null ||
        ap.currentUser == null ||
        _imageFileName == null) {
      return;
    }

    try {
      _isUploading = true;
      notifyListeners();

      String base64Image = base64Encode(_imageBytes!);
      _imageUrl = await ProfileImageRepository.uploadUserPhoto(
        base64Image,
        token!,
      );

      final currentUser = User(
        id: _ref.read(authProvider).currentUser!.id,
        name: _ref.read(authProvider).currentUser!.name,
        email: _ref.read(authProvider).currentUser!.email,
        profilePhoto: _imageUrl,
        createdAt: _ref.read(authProvider).currentUser!.createdAt,
        updatedAt: _ref.read(authProvider).currentUser!.updatedAt,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
      await _ref.read(authProvider).saveUserToPreferences(currentUser);

      _isUploading = false;
      notifyListeners();
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _loadProfileImage() async {
    final ap = _ref.read(authProvider);

    try {
      // Clear previous image URL if the user changed
      if (ap.currentUser == null) {
        _imageUrl = null;
      } else if (_imageUrl == null && ap.currentUser?.profilePhoto != null) {
        _imageUrl = ap.currentUser!.profilePhoto;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading profile image: $e');
      _imageUrl = null; // Explicitly clear the image URL on error
      notifyListeners();
    }
  }

  Future<void> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imageFileName = pickedFile.name;
      _imageBytes = await pickedFile.readAsBytes();
      notifyListeners();
    }
  }
}
