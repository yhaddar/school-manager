import 'package:flutter/material.dart';
import '../models/user.dart';
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
  User? _user;

  AuthProvider({required this.authService});

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  User? get user => _user;
  
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isTeacher => _user?.isTeacher ?? false;
  bool get isStudent => _user?.isStudent ?? false;
  bool get isParent => _user?.isParent ?? false;

  Future<void> initialize() async {
    final result = await authService.getCurrentUser();
    if (result.user != null) {
      _user = result.user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    final result = await authService.getCurrentUser();
    if (result.user != null) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } else {
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<AuthResponse> login(String email, String password) async {
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();

    final response = await authService.login(email, password);

    if (response.success) {
      await loadUser();
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
      await loadUser();
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
    _user = null;
    await authService.logout();
    notifyListeners();
  }
}
