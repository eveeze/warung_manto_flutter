import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Menyimpan token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Mendapatkan token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Menghapus token
  static Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Menyimpan data user
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: json.encode(userData));
  }

  // Mendapatkan data user
  static Future<Map<String, dynamic>?> getUserData() async {
    String? userDataString = await _storage.read(key: _userKey);
    return userDataString != null ? json.decode(userDataString) : null;
  }

  // Menghapus data user
  static Future<void> removeUserData() async {
    await _storage.delete(key: _userKey);
  }

  // Logout
  static Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('http://103.127.138.32/api/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Hapus token dan data user lokal
        await removeToken();
        await removeUserData();
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  // Validasi token
  static Future<bool> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/auth/validate-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
