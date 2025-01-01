import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _baseUrl = 'http://103.127.138.32/api/auth';

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

  static Future<bool> sendForgotPasswordOTP(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending forgot password OTP: $e');
      return false;
    }
  }

  static Future<bool> verifyResetPasswordOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-reset-password-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'otp': otp,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying reset password OTP: $e');
      return false;
    }
  }

  static Future<bool> resendResetPasswordOTP(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/resend-reset-password-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error resending reset password OTP: $e');
      return false;
    }
  }

  static Future<bool> resetPassword({
    required String phone,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // Metode tambahan untuk menangani error lebih detail
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 404:
        return 'User not found.';
      case 403:
        return 'Access denied.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
