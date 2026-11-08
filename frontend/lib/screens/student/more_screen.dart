import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';
import '../../providers/auth_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
              ),
              const SizedBox(height: AppTheme.space16),
              Expanded(
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Iconsax.profile_circle,
                      title: 'Profile',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigate to Profile')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Iconsax.calendar,
                      title: 'School Calendar',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigate to Calendar')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigate to Notifications')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Iconsax.info_circle,
                      title: 'About',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('About')),
                        );
                      },
                    ),
                    const Spacer(),
                    _buildMenuItem(
                      icon: Iconsax.logout,
                      title: 'Logout',
                      isDestructive: true,
                      onTap: () {
                        authProvider.logout();
                        Get.offAllNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.danger : AppTheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.danger : AppTheme.onSurface,
        ),
      ),
      trailing: Icon(Iconsax.arrow_right, color: AppTheme.onSurface),
      onTap: onTap,
    );
  }
}
