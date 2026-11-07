import 'package:flutter/material.dart';

import '../../main.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          // Navigate based on selection
        },
        selectedIndex: 0,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.dashboard),
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            label: 'People',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            label: 'Academics',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            label: 'Operations',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
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
                    icon: Icons.school,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: _StatCard(
                    title: 'Teachers',
                    value: '84',
                    icon: Icons.person,
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
                    icon: Icons.class_,
                    color: AppTheme.info,
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: _StatCard(
                    title: 'Parent Links',
                    value: '1,182',
                    icon: Icons.family_restroom,
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
                  return const ListTile(
                    leading: Icon(Icons.assignment_ind),
                    title: Text('New student enrollment'),
                    subtitle: Text('2 minutes ago'),
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
