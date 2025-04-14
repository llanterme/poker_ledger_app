import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:poker_ledger/models/user.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _userKey = 'current_user';

  // Store current user
  Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _secureStorage.write(key: _userKey, value: userJson);
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Get current user
  Future<User?> getUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        return User.fromJson(userMap);
      }
    } catch (e) {
      debugPrint('Error retrieving user: $e');
      // If there's an error, clear the stored user data to prevent future errors
      await _secureStorage.delete(key: _userKey);
    }
    return null;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final user = await getUser();
    return user != null;
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final user = await getUser();
    return user?.isAdmin ?? false;
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: _userKey);
  }
}
