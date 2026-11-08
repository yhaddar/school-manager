import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import '../models/user.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final String? refreshToken;
  final DateTime? accessExpiry;
  final DateTime? refreshExpiry;

  AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.refreshToken,
    this.accessExpiry,
    this.refreshExpiry,
  });
}

class AuthApiResult {
  final User? user;
  final TenantContext? tenantContext;
  final bool isAuthenticated;

  const AuthApiResult({
    this.user,
    this.tenantContext,
    this.isAuthenticated = false,
  });
}

class AuthService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  AuthService({required this.apiClient, required this.sharedPreferences});

  Future<AuthApiResult> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) {
        return const AuthApiResult(isAuthenticated: false);
      }

      // Set the token on the apiClient before making the request
      apiClient.setToken(token);

      final response = await apiClient.get('/api/v1/user');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['data']);

        final tenantResponse = await apiClient.get('/api/v1/tenant-context');
        TenantContext? tenantContext;
        if (tenantResponse.statusCode == 200) {
          final tenantData = jsonDecode(tenantResponse.body);
          tenantContext = TenantContext.fromJson(tenantData['data']);
        }

        return AuthApiResult(
          user: user,
          tenantContext: tenantContext,
          isAuthenticated: true,
        );
      } else {
        return const AuthApiResult(isAuthenticated: false);
      }
    } catch (e) {
      return const AuthApiResult(isAuthenticated: false);
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    DateTime accessExpiry,
    DateTime refreshExpiry,
  ) async {
    await _secureStorage.write(key: _tokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await sharedPreferences.setString(
      'access_expiry',
      accessExpiry.toIso8601String(),
    );
    await sharedPreferences.setString(
      'refresh_expiry',
      refreshExpiry.toIso8601String(),
    );
    apiClient.setToken(accessToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await sharedPreferences.remove(_userIdKey);
    apiClient.clearToken();
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/api/v1/auth/sessions',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final tokenData = data['data'];
        final accessTokenExpiry = DateTime.parse(
          tokenData['access_expires_at'],
        );
        final refreshTokenExpiry = DateTime.parse(
          tokenData['refresh_expires_at'],
        );

        await _saveTokens(
          tokenData['access_token'],
          tokenData['refresh_token'],
          accessTokenExpiry,
          refreshTokenExpiry,
        );

        return AuthResponse(
          success: true,
          token: tokenData['access_token'],
          refreshToken: tokenData['refresh_token'],
          accessExpiry: accessTokenExpiry,
          refreshExpiry: refreshTokenExpiry,
        );
      } else {
        return AuthResponse(success: false, message: 'Invalid credentials');
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error');
    }
  }

  Future<AuthResponse> activateAccount({
    required String username,
    required String temporaryPassword,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/auth/activation',
        body: {
          'username': username,
          'temporary_password': temporaryPassword,
          'password': password,
          'password_confirmation': password,
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final tokenData = data['data'];

        final accessTokenExpiry = DateTime.parse(
          tokenData['access_expires_at'],
        );
        final refreshTokenExpiry = DateTime.parse(
          tokenData['refresh_expires_at'],
        );

        await _saveTokens(
          tokenData['access_token'],
          tokenData['refresh_token'],
          accessTokenExpiry,
          refreshTokenExpiry,
        );

        return AuthResponse(
          success: true,
          token: tokenData['access_token'],
          refreshToken: tokenData['refresh_token'],
          accessExpiry: accessTokenExpiry,
          refreshExpiry: refreshTokenExpiry,
        );
      } else {
        final data = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Activation failed',
        );
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error');
    }
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        '/api/v1/auth/sessions/refresh',
        body: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokenData = data['data'];

        final accessTokenExpiry = DateTime.parse(
          tokenData['access_expires_at'],
        );
        final refreshTokenExpiry = DateTime.parse(
          tokenData['refresh_expires_at'],
        );

        await _saveTokens(
          tokenData['access_token'],
          tokenData['refresh_token'],
          accessTokenExpiry,
          refreshTokenExpiry,
        );

        return AuthResponse(
          success: true,
          token: tokenData['access_token'],
          refreshToken: tokenData['refresh_token'],
          accessExpiry: accessTokenExpiry,
          refreshExpiry: refreshTokenExpiry,
        );
      } else {
        await clearTokens();
        return AuthResponse(success: false, message: 'Session expired');
      }
    } catch (e) {
      await clearTokens();
      return AuthResponse(success: false, message: 'Network error');
    }
  }

  Future<void> logout() async {
    await apiClient.delete('/api/v1/auth/sessions/current');
    await clearTokens();
  }
}
