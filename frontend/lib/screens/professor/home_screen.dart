import 'package:flutter/material.dart';

import '../../main.dart';

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
      body: const ProfessorTodayView(),
    );
  }
}

class ProfessorTodayView extends StatelessWidget {
  const ProfessorTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Professor',
              style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space16),
            
            const Text(
              'Your schedule for today:',
              style: AppTextTheme.title,
            ),
            const SizedBox(height: AppTheme.space16),
            
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: Icon(Icons.book, color: AppTheme.onPrimary),
                    ),
                    title: Text('Mathematics'),
                    subtitle: Text('Room 201 • 09:00 - 10:30'),
                    trailing: Icon(Icons.access_time),
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
