import 'package:flutter/material.dart';

class ProfessorMessagesScreen extends StatelessWidget {
  const ProfessorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isUnread = index % 3 == 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('J'),
              ),
              title: Row(
                children: [
                  Text('John Smith'),
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.circle, size: 12, color: Theme.of(context).colorScheme.primary),
                  ],
                ],
              ),
              subtitle: Text(
                index == 0 
                  ? 'Your request for the Mathematics curriculum has been approved.'
                  : 'Hi Professor, can you review the assignment?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text('${5 - index}h'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to message')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compose new message')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
