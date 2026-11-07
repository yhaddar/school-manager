import 'package:flutter/material.dart';

class ProfessorClassesScreen extends StatelessWidget {
  const ProfessorClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                child: Icon(Icons.class_, color: Theme.of(context).colorScheme.primary),
              ),
              title: const Text('Mathematics - Grade 10'),
              subtitle: const Text('25 students · Room 201'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to class roster')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
