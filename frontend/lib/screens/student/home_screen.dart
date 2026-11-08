import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';
import 'learning_screen.dart';
import 'tasks_screen.dart';
import 'results_screen.dart';
import 'more_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const _StudentTodayView(),
    const LearningScreen(),
    const TasksScreen(),
    const ResultsScreen(),
    const MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Iconsax.notification, color: AppTheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Iconsax.profile_circle, color: AppTheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        backgroundColor: AppTheme.surface,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Iconsax.clock, color: AppTheme.primary),
            icon: Icon(Iconsax.clock, color: AppTheme.muted),
            label: 'Today',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.book, color: AppTheme.primary),
            icon: Icon(Iconsax.book, color: AppTheme.muted),
            label: 'Learning',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.task, color: AppTheme.primary),
            icon: Icon(Iconsax.task, color: AppTheme.muted),
            label: 'Tasks',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.graph, color: AppTheme.primary),
            icon: Icon(Iconsax.graph, color: AppTheme.muted),
            label: 'Results',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.more, color: AppTheme.primary),
            icon: Icon(Iconsax.more, color: AppTheme.muted),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _StudentTodayView extends StatelessWidget {
  const _StudentTodayView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Alex',
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
                      "Today's Schedule",
                      style: AppTextTheme.title.copyWith(color: AppTheme.onSurface),
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
            
            const SizedBox(height: AppTheme.space24),
            
            Text(
              'Upcoming Assignments',
              style: AppTextTheme.h2.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space16),
            _BuildAssignmentItem(
              title: 'Chapter 5 Exercises',
              course: 'Mathematics',
              dueDate: 'Tomorrow',
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
      leading: Icon(Iconsax.clock, color: AppTheme.primary),
      title: Text(subject, style: TextStyle(color: AppTheme.onSurface)),
      subtitle: Text('$teacher • $time', style: TextStyle(color: AppTheme.muted)),
    );
  }
}

class _BuildAssignmentItem extends StatelessWidget {
  final String title;
  final String course;
  final String dueDate;

  const _BuildAssignmentItem({
    required this.title,
    required this.course,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Iconsax.task, color: AppTheme.primary),
        title: Text(title, style: TextStyle(color: AppTheme.onSurface)),
        subtitle: Text('$course • Due $dueDate', style: TextStyle(color: AppTheme.muted)),
        trailing: Icon(Iconsax.arrow_right, color: AppTheme.onSurface),
      ),
    );
  }
}
