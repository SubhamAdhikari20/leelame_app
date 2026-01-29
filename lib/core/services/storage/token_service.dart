// lib/core/services/storage/token_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return TokenService(prefs: sharedPreferences);
});

class TokenService {
  final SharedPreferences _prefs;
  static const String _tokenKey = "auth_token";

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  // save token : secure storage
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  // get token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  // remove token
  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }
}
