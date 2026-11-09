import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space16),
        children: [
          const SizedBox(height: AppTheme.space16),
          Card(
            child: ListTile(
              leading: Icon(Iconsax.profile_circle, color: AppTheme.primary),
              title: const Text('Profile'),
              trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
              onTap: () {
                // Navigate to profile
              },
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Card(
            child: ListTile(
              leading: Icon(Iconsax.security, color: AppTheme.primary),
              title: const Text('Security'),
              trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
              onTap: () {
                // Navigate to security settings
              },
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Card(
            child: ListTile(
              leading: Icon(Iconsax.direct_notification, color: AppTheme.primary),
              title: const Text('Notifications'),
              trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
              onTap: () {
                // Navigate to notifications
              },
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Card(
            child: ListTile(
              leading: Icon(Iconsax.info_circle, color: AppTheme.primary),
              title: const Text('About'),
              trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
              onTap: () {
                // Navigate to about
              },
            ),
          ),
          const SizedBox(height: AppTheme.space32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Iconsax.logout),
              label: const Text('Logout'),
              onPressed: () {
                // Logout functionality
              },
            ),
          ),
        ],
      ),
    );
  }
}
