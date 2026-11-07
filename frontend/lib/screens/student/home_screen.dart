import 'package:flutter/material.dart';

import '../../main.dart';

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
      body: const StudentHomeView(),
    );
  }
}

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Alex',
              style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Schedule',
                      style: AppTextTheme.title,
                    ),
                    const SizedBox(height: AppTheme.space16),
                    _ScheduleItem(
                      subject: 'Mathematics',
                      teacher: 'Mr. Smith',
                      time: '09:00 - 10:30',
                    ),
                    _ScheduleItem(
                      subject: 'English',
                      teacher: 'Ms. Johnson',
                      time: '10:45 - 12:00',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String subject;
  final String teacher;
  final String time;

  const _ScheduleItem({
    required this.subject,
    required this.teacher,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.access_time, color: AppTheme.primary),
      title: Text(subject),
      subtitle: Text('$teacher • $time'),
    );
  }
}
