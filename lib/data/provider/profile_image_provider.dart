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

  // Memory cache for storing image bytes
  static final Map<String, Uint8List> _imageCache = {};

  Uint8List? get imageBytes => _imageBytes;
  String? get imageUrl => _imageUrl;
  String? get imageFileName => _imageFileName;
  bool get isUploading => _isUploading;

  ProfileImageController(this._ref) {
    _initializeProfileImage();
  }

  Future<void> _initializeProfileImage() async {
    await Future.doWhile(() async {
      final ap = _ref.read(authProvider);
      if (ap.currentUser != null) {
        await loadOrFetchProfileImage();
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    });
  }

  Future<void> loadOrFetchProfileImage() async {
    final token = await AuthRepository.retrieveToken();
    final ap = _ref.read(authProvider);

    try {
      if (ap.currentUser == null || ap.currentUser!.profilePhoto == null) {
        _imageBytes = null;
        _imageUrl = null;
        notifyListeners();
        return;
      }

      final imagePath = ap.currentUser!.profilePhoto!;

      // Check if image is in memory cache
      if (_imageCache.containsKey(imagePath)) {
        _imageBytes = _imageCache[imagePath];
        _imageUrl = imagePath;
        notifyListeners();
        return;
      }

      // Reset image bytes when loading new image
      _imageBytes = null;
      _imageUrl = null;
      notifyListeners();

      final imageBytes = await ProfileImageRepository.retrieveUserPhoto(
        imagePath,
        token!,
      );

      // Store in memory cache
      _imageCache[imagePath] = imageBytes;

      _imageBytes = imageBytes;
      _imageUrl = imagePath;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile image: $e');
      _imageBytes = null;
      _imageUrl = null;
      notifyListeners();
    }
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
      final newImageUrl = await ProfileImageRepository.uploadUserPhoto(
        base64Image,
        token!,
      );

      if (newImageUrl != null) {
        // Clear old image from cache
        if (_imageUrl != null) {
          _imageCache.remove(_imageUrl);
        }

        // Store new image in cache
        _imageCache[newImageUrl] = _imageBytes!;
        _imageUrl = newImageUrl;

        final currentUser = User(
          id: ap.currentUser!.id,
          name: ap.currentUser!.name,
          email: ap.currentUser!.email,
          profilePhoto: _imageUrl,
          createdAt: ap.currentUser!.createdAt,
          updatedAt: ap.currentUser!.updatedAt,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('currentUser');
        await _ref.read(authProvider).saveUserToPreferences(currentUser);
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // Limit image size
      maxHeight: 800,
      imageQuality: 85, // Compress image
    );

    if (pickedFile != null) {
      _imageFileName = pickedFile.name;
      _imageBytes = await pickedFile.readAsBytes();
      notifyListeners();
    }
  }

  // Method to clear cache if needed
  static void clearCache() {
    _imageCache.clear();
  }
}
