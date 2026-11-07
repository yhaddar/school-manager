import 'package:flutter/material.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academics'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Structure',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _AcademicsGrid(),
          ],
        ),
      ),
    );
  }
}

class _AcademicsGrid extends StatelessWidget {
  const _AcademicsGrid();

  static const List<Map<String, dynamic>> _academicItems = [
    {'title': 'Academic Years', 'icon': Icons.calendar_today},
    {'title': 'Academic Periods', 'icon': Icons.event},
    {'title': 'Levels', 'icon': Icons.school},
    {'title': 'Tracks', 'icon': Icons.route},
    {'title': 'Departments', 'icon': Icons.domain},
    {'title': 'Classes', 'icon': Icons.class_outlined},
    {'title': 'Groups', 'icon': Icons.group},
    {'title': 'Subjects', 'icon': Icons.book},
    {'title': 'Courses', 'icon':Icons.reviews},
    {'title': 'Rooms', 'icon': Icons.chair},
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _academicItems.length,
        itemBuilder: (context, index) {
          final item = _academicItems[index];
          return Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigate to ${item['title']}')),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item['icon'] as IconData, size: 32, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      item['title'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
