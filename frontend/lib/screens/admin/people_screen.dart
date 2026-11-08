import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('People'),
        actions: [
          IconButton(
            icon: Icon(Iconsax.search_normal, color: AppTheme.onSurface),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          // Navigate based on selection
        },
        selectedIndex: 1,
        backgroundColor: AppTheme.surface,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Iconsax.activity, color: AppTheme.primary),
            icon: Icon(Iconsax.activity, color: AppTheme.muted),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.user_square, color: AppTheme.primary),
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
      body: const PeopleListView(),
    );
  }
}

class PeopleListView extends StatelessWidget {
  const PeopleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'People Directory',
              style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'Search, filter, and manage staff, students, and parents.',
              style: AppTextTheme.body.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: AppTheme.space24),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const PersonListItem(
                    name: 'John Smith',
                    role: 'Teacher',
                    email: 'john.smith@school.edu',
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

class PersonListItem extends StatelessWidget {
  final String name;
  final String role;
  final String email;

  const PersonListItem({
    super.key,
    required this.name,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Icon(Iconsax.user_square, color: AppTheme.onPrimary),
        ),
        title: Text(name, style: TextStyle(color: AppTheme.onSurface)),
        subtitle: Text('$role • $email', style: TextStyle(color: AppTheme.muted)),
        trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
        onTap: () {
          // Navigate to person profile
        },
      ),
    );
  }
}
