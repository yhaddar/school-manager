import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('School Manager'),
        actions: [
          IconButton(
            icon: Icon(Iconsax.direct_notification, color: AppTheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Iconsax.profile_circle, color: AppTheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          // Navigate based on selection
        },
        selectedIndex: 0,
        backgroundColor: AppTheme.surface,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Iconsax.activity, color: AppTheme.primary),
            icon: Icon(Iconsax.activity, color: AppTheme.muted),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.user_square, color: AppTheme.muted),
            label: 'People',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.book, color: AppTheme.muted),
            label: 'Academics',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.settings, color: AppTheme.muted),
            label: 'Operations',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.more, color: AppTheme.muted),
            label: 'More',
          ),
        ],
      ),
      body: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Text(
              'Welcome back',
              style: AppTextTheme.h2.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              'Manage your institution',
              style: AppTextTheme.body.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: AppTheme.space24),
            
            // Quick stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Students',
                    value: '1,248',
                    icon: Iconsax.book,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: _StatCard(
                    title: 'Teachers',
                    value: '84',
                    icon: Iconsax.user_square,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Classes',
                    value: '32',
                    icon: Iconsax.clock,
                    color: AppTheme.info,
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: _StatCard(
                    title: 'Parent Links',
                    value: '1,182',
                    icon: Iconsax.user_square,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space24),
            
            // Recent activity section
            Text(
              'Recent Activity',
              style: AppTextTheme.h3.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space16),
            
            // Activity list
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Iconsax.calendar, color: AppTheme.primary),
                    title: Text('New student enrollment', style: TextStyle(color: AppTheme.onSurface)),
                    subtitle: Text('2 minutes ago', style: TextStyle(color: AppTheme.muted)),
                    trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: AppTheme.space8),
                Text(title, style: AppTextTheme.small.copyWith(color: AppTheme.muted)),
              ],
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              value,
              style: AppTextTheme.h3.copyWith(color: AppTheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
