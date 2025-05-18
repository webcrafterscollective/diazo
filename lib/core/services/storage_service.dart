// lib/core/services/storage_service.dart
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart'; // Import UserModel
import 'dart:convert'; // Import dart:convert for JSON encoding/decoding

class StorageService {
  final _box = GetStorage('AuthData'); // Use a named container for clarity
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  // --- Token Methods ---
  Future<void> saveToken(String token) async {
    await _box.write(_tokenKey, token);
    print('Token saved: $token'); // For debugging
  }

  Future<String?> getToken() async {
    final token = _box.read(_tokenKey);
    print('Token read (async): $token'); // For debugging
    return token;
  }

  String? getTokenSync() {
    final token = _box.read(_tokenKey);
    print('Token read (sync): $token'); // For debugging
    return token;
  }

  Future<void> removeToken() async {
    await _box.remove(_tokenKey);
    print('Token removed'); // For debugging
  }

  // --- User Data Methods ---
  // Save UserModel object by encoding it to JSON string
  Future<void> saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson()); // Encode UserModel to JSON
    await _box.write(_userKey, userJson);
    print('User saved: ${user.email}'); // For debugging
  }

  // Retrieve UserModel object by decoding JSON string
  Future<UserModel?> getUser() async {
    final userJson = _box.read<String>(_userKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap); // Decode JSON to UserModel
        print('User read (async): ${user.email}'); // For debugging
        return user;
      } catch (e) {
        print("Error decoding user JSON: $e"); // Add error handling
        await removeUser(); // Clear corrupted data
        return null;
      }
    }
    print('User read (async): Not found'); // For debugging
    return null;
  }

  // Synchronous version for immediate checks if needed, though less common for user object
  UserModel? getUserSync() {
    final userJson = _box.read<String>(_userKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        print('User read (sync): ${user.email}'); // For debugging
        return user;
      } catch (e) {
        print("Error decoding user JSON (sync): $e"); // Add error handling
        removeUser(); // Clear corrupted data async, okay here
        return null;
      }
    }
    print('User read (sync): Not found'); // For debugging
    return null;
  }


  Future<void> removeUser() async {
    await _box.remove(_userKey);
    print('User removed'); // For debugging
  }

  // --- Clear All ---
  Future<void> clearAll() async {
    await _box.erase();
    print('Storage cleared'); // For debugging
  }
}