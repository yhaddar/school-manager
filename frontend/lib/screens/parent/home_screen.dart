import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';

import '../../main.dart';
import 'more_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const _ParentHomeView(),
    const _ChildrenView(),
    const _PaymentsView(),
    const _MessagesView(),
    const ParentMoreScreen(),
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
            selectedIcon: Icon(Iconsax.home, color: AppTheme.primary),
            icon: Icon(Iconsax.home, color: AppTheme.muted),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.user_square, color: AppTheme.muted),
            label: 'Children',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.money, color: AppTheme.muted),
            label: 'Payments',
          ),
          NavigationDestination(
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

class ChildInfo {
  final String name;
  final String grade;

  const ChildInfo({required this.name, this.grade = ''});
}

class _ParentHomeView extends StatelessWidget {
  static const List<ChildInfo> children = [
    ChildInfo(name: 'Alex Johnson'),
    ChildInfo(name: 'Emma Johnson'),
  ];

  const _ParentHomeView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good afternoon, Sarah',
              style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space24),
            
            const Text(
              'Your Children',
              style: AppTextTheme.h2,
            ),
            const SizedBox(height: AppTheme.space16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: Icon(Iconsax.user_square, color: AppTheme.onPrimary),
                    ),
                    title: Text(child.name, style: TextStyle(color: AppTheme.onSurface)),
                    trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
                    onTap: () {
                      // Handle child selection
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildrenView extends StatelessWidget {
  static const List<ChildInfo> children = [
    ChildInfo(name: 'Alex Johnson', grade: 'Grade 5'),
    ChildInfo(name: 'Emma Johnson', grade: 'Grade 3'),
  ];

  const _ChildrenView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Children',
              style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space24),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: Icon(Iconsax.user_square, color: AppTheme.onPrimary),
                    ),
                    title: Text(child.name, style: TextStyle(color: AppTheme.onSurface)),
                    subtitle: Text(child.grade, style: TextStyle(color: AppTheme.muted)),
                    trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
                    onTap: () {
                      // Handle child profile tap
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  const _PaymentsView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.money, size: 64, color: AppTheme.primary),
            const SizedBox(height: AppTheme.space24),
            Text(
              'Payments',
              style: AppTextTheme.h2.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space16),
            const Text('No pending payments at this time.'),
          ],
        ),
      ),
    );
  }
}

class _MessagesView extends StatelessWidget {
  const _MessagesView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.message, size: 64, color: AppTheme.primary),
            const SizedBox(height: AppTheme.space24),
            Text(
              'Messages',
              style: AppTextTheme.h2.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.space16),
            const Text('No new messages.'),
          ],
        ),
      ),
    );
  }
}
