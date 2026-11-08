import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('Academics'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Structure',
              style: AppTextTheme.h1,
            ),
            SizedBox(height: AppTheme.space16),
            _AcademicsGrid(),
          ],
        ),
      ),
    );
  }
}

class _AcademicsGrid extends StatelessWidget {
  const _AcademicsGrid();

  static final List<Map<String, dynamic>> _academicItems = [
    {'title': 'Academic Years', 'icon': Iconsax.calendar},
    {'title': 'Academic Periods', 'icon': Iconsax.calendar_1},
    {'title': 'Levels', 'icon': Iconsax.level},
    {'title': 'Tracks', 'icon': Iconsax.book_1},
    {'title': 'Departments', 'icon': Iconsax.category},
    {'title': 'Classes', 'icon': Iconsax.clock},
    {'title': 'Groups', 'icon': Iconsax.group},
    {'title': 'Subjects', 'icon': Iconsax.book},
    {'title': 'Courses', 'icon': Iconsax.clipboard},
    {'title': 'Rooms', 'icon': Iconsax.location},
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
                padding: const EdgeInsets.all(AppTheme.space16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon((item['icon'] as IconData), size: 32, color: AppTheme.primary),
                    const SizedBox(height: AppTheme.space12),
                    Text(
                      item['title'] as String,
                      style: AppTextTheme.title.copyWith(color: AppTheme.onSurface),
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
