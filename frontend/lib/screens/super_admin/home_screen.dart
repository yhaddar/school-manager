import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class SuperAdminHomeScreen extends StatelessWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SuperAdminDashboard();
  }
}

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _currentIndex = 0;

  static const List<Widget> _children = [
    _InstitutionsTab(),
    _AnalyticsTab(),
    _SettingsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.direct_notification),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.user),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.building),
            label: 'Institutions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.barcode),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _InstitutionsTab extends StatelessWidget {
  const _InstitutionsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Institutions',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space16),
          const Padding(
            padding: EdgeInsets.all(AppTheme.space16),
            child: Text(
              '0',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          Text(
            'Recent Institutions',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space16),
          const Center(
            child: Icon(Iconsax.building, size: 48, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Analytics',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space16),
          Text(
            'Active Institutions',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Iconsax.building),
            title: Text('Loading...'),
            trailing: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.space16),
      children: [
        Text(
          'Settings',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.space16),
        const ListTile(
          leading: Icon(Iconsax.profile_circle),
          title: Text('Profile'),
        ),
        const ListTile(
          leading: Icon(Iconsax.shield),
          title: Text('Security'),
        ),
        const ListTile(
          leading: Icon(Iconsax.direct_notification),
          title: Text('Notifications'),
        ),
      ],
    );
  }
}
