import 'package:flutter/material.dart';

import '../../main.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  static const List<ChildInfo> _children = [
    ChildInfo(name: 'Alex Johnson'),
    ChildInfo(name: 'Emma Johnson'),
  ];

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
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.family_restroom_outlined),
            label: 'Children',
          ),
          NavigationDestination(
            icon: Icon(Icons.payment_outlined),
            label: 'Payments',
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
      body: ParentHomeView(children: _children),
    );
  }
}

class ChildInfo {
  final String name;

  const ChildInfo({required this.name});
}

class ParentHomeView extends StatelessWidget {
  final List<ChildInfo> children;

  const ParentHomeView({super.key, required this.children});

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
            
            // Child switcher - explicit selection as per DESIGN.md
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(child.name),
                    trailing: const Icon(Icons.chevron_right),
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
