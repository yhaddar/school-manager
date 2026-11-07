import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

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
            icon: Icon(Icons.book_outlined),
            label: 'Learning',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Results',
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
