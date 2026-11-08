import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';
import '../../providers/auth_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space16),
        children: [
          const ListTile(
            title: Text('Settings'),
            leading: Icon(Iconsax.settings, color: AppTheme.primary),
            trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            title: Text('Profile', style: TextStyle(color: AppTheme.onSurface)),
            leading: Icon(Iconsax.profile_circle, color: AppTheme.primary),
            trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Profile')),
              );
            },
          ),
          ListTile(
            title: Text('Sessions / Devices', style: TextStyle(color: AppTheme.onSurface)),
            leading: Icon(Iconsax.devices, color: AppTheme.primary),
            trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Sessions')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            title: Text('Notification Preferences', style: TextStyle(color: AppTheme.onSurface)),
            leading: Icon(Iconsax.direct_notification, color: AppTheme.primary),
            trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Notification Preferences')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
            child: Text(
              'Support',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            title: Text('Help / Support', style: TextStyle(color: AppTheme.onSurface)),
            leading: Icon(Iconsax.support, color: AppTheme.primary),
            trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Help')),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text('Logout', style: TextStyle(color: AppTheme.danger)),
            leading: Icon(Iconsax.logout, color: AppTheme.danger),
            onTap: () {
              authProvider.logout();
            },
          ),
        ],
      ),
    );
  }
}
