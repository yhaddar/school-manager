import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class ProfessorMessagesScreen extends StatelessWidget {
  const ProfessorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.space16),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isUnread = index % 3 == 0;
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.space8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: Text('J', style: TextStyle(color: AppTheme.onPrimary)),
              ),
              title: Row(
                children: [
                  Text('John Smith', style: TextStyle(color: AppTheme.onSurface)),
                  if (isUnread) ...[
                    const SizedBox(width: AppTheme.space8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                index == 0 
                  ? 'Your request for the Mathematics curriculum has been approved.'
                  : 'Hi Professor, can you review the assignment?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.muted),
              ),
              trailing: Text('${5 - index}h', style: TextStyle(color: AppTheme.muted)),
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
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compose new message')),
          );
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }
}
