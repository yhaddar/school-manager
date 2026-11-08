import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('Operations'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operations Management',
              style: AppTextTheme.h1,
            ),
            SizedBox(height: AppTheme.space16),
            _OperationsGrid(),
          ],
        ),
      ),
    );
  }
}

class _OperationsGrid extends StatelessWidget {
  const _OperationsGrid();

  static final List<Map<String, dynamic>> _operationItems = [
    {'title': 'Attendance', 'icon': Iconsax.calendar, 'color': AppTheme.info},
    {'title': 'Fees', 'icon': Iconsax.money, 'color': AppTheme.primary},
    {'title': 'Payments', 'icon': Iconsax.wallet, 'color': AppTheme.warning},
    {'title': 'Documents', 'icon': Iconsax.document, 'color': AppTheme.info},
    {'title': 'Reports', 'icon': Iconsax.chart, 'color': AppTheme.danger},
    {'title': 'Discipline', 'icon': Iconsax.warning_2, 'color': AppTheme.warning},
    {'title': 'Library', 'icon': Iconsax.book, 'color': AppTheme.info},
    {'title': 'Transport', 'icon': Iconsax.bus, 'color': AppTheme.success},
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
        itemCount: _operationItems.length,
        itemBuilder: (context, index) {
          final item = _operationItems[index];
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
                    Icon((item['icon'] as IconData), size: 32, color: (item['color'] as Color)),
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
