import 'package:flutter/material.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operations Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _OperationsGrid(),
          ],
        ),
      ),
    );
  }
}

class _OperationsGrid extends StatelessWidget {
  const _OperationsGrid();

  static const _operationItems = [
    {'title': 'Attendance', 'icon': Icons.event_note, 'color': Color(0xFF1D4ED8)},
    {'title': 'Fees', 'icon': Icons.payment, 'color': Color(0xFF0F766E)},
    {'title': 'Payments', 'icon': Icons.account_balance, 'color': Color(0xFF92400E)},
    {'title': 'Documents', 'icon': Icons.description, 'color': Color(0xFF8B5CF6)},
    {'title': 'Reports', 'icon': Icons.bar_chart, 'color': Color(0xFFEF4444)},
    {'title': 'Discipline', 'icon': Icons.warning, 'color': Color(0xFFF59E0B)},
    {'title': 'Library', 'icon': Icons.menu_book, 'color': Color(0xFF3B82F6)},
    {'title': 'Transport', 'icon': Icons.directions_bus, 'color': Color(0xFF10B981)},
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item['icon'] as IconData, size: 32, color: item['color'] as Color),
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
