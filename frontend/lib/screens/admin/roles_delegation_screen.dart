import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class RolesDelegationScreen extends StatelessWidget {
  const RolesDelegationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('Roles & Permissions'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(AppTheme.space16),
            child: Text(
              'Manage role assignments and permissions for staff and teachers',
              style: AppTextTheme.body.copyWith(color: AppTheme.onSurface),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.space16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.space12),
                  child: ListTile(
                    title: Text('User Profile', style: TextStyle(color: AppTheme.onSurface)),
                    subtitle: Text('Role: Admin', style: TextStyle(color: AppTheme.muted)),
                    trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Role management coming soon')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new role assignment')),
          );
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }
}
