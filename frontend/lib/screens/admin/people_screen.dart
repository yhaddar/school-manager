import 'package:flutter/material.dart';
import '../../main.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.dashboard),
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.people),
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
            const Text(
              'Search, filter, and manage staff, students, and parents.',
              style: AppTextTheme.body,
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
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(name),
        subtitle: Text(' • '),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to person profile
        },
      ),
    );
  }
}
