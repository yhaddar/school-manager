import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/auth_provider.dart';
import '../../main.dart';

class ActivateScreen extends StatefulWidget {
  const ActivateScreen({super.key});

  @override
  State<ActivateScreen> createState() => _ActivateScreenState();
}

class _ActivateScreenState extends State<ActivateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _tempPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _tempPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.activateAccount(
      username: _usernameController.text.trim(),
      temporaryPassword: _tempPasswordController.text,
      password: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      // Navigate to the user's role-based home
      final user = authProvider.user;
      if (user != null) {
        if (user.isAdmin) {
          Get.offAllNamed('/admin/home');
        } else if (user.isTeacher) {
          Get.offAllNamed('/professor/home');
        } else if (user.isStudent) {
          Get.offAllNamed('/student/home');
        } else if (user.isParent) {
          Get.offAllNamed('/parent/home');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Activation failed')),
      );
    }
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
              children: [
                Text(
                  'Activate your account',
                  style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
                ),
                const SizedBox(height: AppTheme.space24),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Iconsax.user_square, color: AppTheme.primary),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.onSurface),
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                TextFormField(
                  controller: _tempPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Temporary Password',
                    prefixIcon: Icon(Iconsax.lock, color: AppTheme.primary),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.onSurface),
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your temporary password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Iconsax.lock, color: AppTheme.primary),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.onSurface),
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 12) {
                      return 'Password must be at least 12 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Iconsax.lock, color: AppTheme.primary),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.onSurface),
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.space24),
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
                        : const Text('Activate'),
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
