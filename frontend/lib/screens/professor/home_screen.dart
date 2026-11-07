import 'package:flutter/material.dart';

class ProfessorHomeScreen extends StatelessWidget {
  const ProfessorHomeScreen({super.key});

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
        onDestinationSelected: (int index) {},
        selectedIndex: 0,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.access_time),
            icon: Icon(Icons.access_time_outlined),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            label: 'Assessments',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            label: 'More',
          ),
        ],
      ),
      body: const Center(
        child: Text('Today content'),
      ),
    );
  }
}
