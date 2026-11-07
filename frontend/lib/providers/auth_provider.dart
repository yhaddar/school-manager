import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  activating,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  
  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;

  AuthProvider({required this.authService});

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> initialize() async {
    final isLoggedIn = await authService.isLoggedIn();
    if (isLoggedIn) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<AuthResponse> login(String email, String password) async {
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();

    final response = await authService.login(email, password);

    if (response.success) {
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = response.message;
      _status = AuthStatus.error;
    }
    notifyListeners();

    return response;
  }

  Future<AuthResponse> activateAccount({
    required String username,
    required String temporaryPassword,
    required String password,
  }) async {
    _status = AuthStatus.activating;
    _errorMessage = null;
    notifyListeners();

    final response = await authService.activateAccount(
      username: username,
      temporaryPassword: temporaryPassword,
      password: password,
    );

    if (response.success) {
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = response.message;
      _status = AuthStatus.error;
    }
    notifyListeners();

    return response;
  }

  Future<void> logout() async {
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    await authService.logout();
    notifyListeners();
  }
}
