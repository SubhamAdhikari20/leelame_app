// lib/core/services/storage/user_session_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    "Shared Preferences should be initialized in main.dart file",
  );
});

// User Session Service Provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Keys for storing data
  static const String _keyIsLoggedIn = "is_logged_in";
  static const String _keyUserId = "user_id";
  static const String _keyUserEmail = "user_email";
  static const String _keyUserRole = "user_role";
  static const String _keyUserFullName = "user_full_name";
  static const String _keyUsername = "username";
  static const String _keyUserPhoneNumber = "user_phone_number";
  static const String _keyUserProfilePictureUrl = "user_profile_picture_url";

  // Store user session data
  Future<void> storeUserSession({
    required String userId,
    required String email,
    required String role,
    required String fullName,
    String? username,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserRole, role);
    await _prefs.setString(_keyUserFullName, fullName);

    if (username != null) {
      await _prefs.setString(_keyUsername, username);
    }
    if (phoneNumber != null) {
      await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    }
    if (profilePictureUrl != null) {
      await _prefs.setString(_keyUserProfilePictureUrl, profilePictureUrl);
    }
  }

  // Clear user session data
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyUserProfilePictureUrl);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  String? getUserRole() {
    return _prefs.getString(_keyUserRole);
  }

  String? getUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  String? getUsername() {
    return _prefs.getString(_keyUsername);
  }

  String? getUserPhoneNumber() {
    return _prefs.getString(_keyUserPhoneNumber);
  }

  String? getUserProfilePictureUrl() {
    return _prefs.getString(_keyUserProfilePictureUrl);
  }
}
