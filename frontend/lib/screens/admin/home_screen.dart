import 'package:flutter/material.dart';

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
      body: const Center(
        child: Text('Dashboard content'),
      ),
    );
  }
}
