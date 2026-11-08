import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';
import 'classes_screen.dart';
import 'assessments_screen.dart';
import 'messages_screen.dart';
import 'more_screen.dart';

class ProfessorHomeScreen extends StatefulWidget {
  const ProfessorHomeScreen({super.key});

  @override
  State<ProfessorHomeScreen> createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    _ProfessorTodayView(),
    ProfessorClassesScreen(),
    ProfessorAssessmentsScreen(),
    ProfessorMessagesScreen(),
    ProfessorMoreScreen(),
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
        title: const Text('School Manager'),
        actions: [
          IconButton(
            icon: Icon(Iconsax.direct_notification, color: AppTheme.onSurface),
            onPressed: () {
              Get.toNamed('/professor/notifications');
            },
          ),
          IconButton(
            icon: Icon(Iconsax.profile_circle, color: AppTheme.onSurface),
            onPressed: () {
              Get.toNamed('/professor/profile');
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        backgroundColor: AppTheme.surface,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Iconsax.clock, color: AppTheme.primary),
            icon: Icon(Iconsax.clock, color: AppTheme.muted),
            label: 'Today',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.book, color: AppTheme.primary),
            icon: Icon(Iconsax.book, color: AppTheme.muted),
            label: 'Classes',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.clipboard, color: AppTheme.primary),
            icon: Icon(Iconsax.clipboard, color: AppTheme.muted),
            label: 'Assessments',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.message, color: AppTheme.primary),
            icon: Icon(Iconsax.message, color: AppTheme.muted),
            label: 'Messages',
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

class _ProfessorTodayView extends StatelessWidget {
  const _ProfessorTodayView();

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
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: Icon(Iconsax.book, color: AppTheme.onPrimary),
                    ),
                    title: Text('Mathematics', style: TextStyle(color: AppTheme.onSurface)),
                    subtitle: Text('Room 201 • 09:00 - 10:30', style: TextStyle(color: AppTheme.muted)),
                    trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
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
