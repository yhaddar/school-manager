import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      // Navigate to the user's role-based home after login
      final user = authProvider.user;
      final targetRoute = _determineTargetRoute(user);
      // Navigate to target route if determined
      if (targetRoute != null) {
        Get.offAllNamed(targetRoute);
      } else if (user != null) {
        // Fallback: navigate to admin home if user exists but role undetermined
        Get.offAllNamed('/admin/home');
      } else {
        // Fallback: stay on login or show error if no valid role
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to determine user role')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Login failed')),
      );
    }
  }

  String? _determineTargetRoute(User? user) {
    if (user == null) return null;
    
    // Determine target route based on user's role/type
    // Priority: membership role (admin/teacher/parent), then user_type (student)
    if (user.isAdmin) {
      return '/admin/home';
    } else if (user.isTeacher) {
      return '/professor/home';
    } else if (user.isStudent) {
      return '/student/home';
    } else if (user.isParent) {
      return '/parent/home';
    }
    
    // Default fallback - could be configured per institution
    return '/admin/home';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Title
                Icon(Iconsax.book, size: 64, color: AppTheme.primary),
                const SizedBox(height: AppTheme.space24),
                Text(
                  'School Manager',
                  style: AppTextTheme.display.copyWith(
                    color: AppTheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space48),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                            prefixIcon: Icon(Iconsax.message, color: AppTheme.primary),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.onSurface),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.space16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Iconsax.lock, color: AppTheme.primary),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.onSurface),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.space24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ),

                // Error message
                if (Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).errorMessage !=
                    null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.space16),
                    child: Text(
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
