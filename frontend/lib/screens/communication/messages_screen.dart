import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../services/message_service.dart';
import '../../models/message_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<List<MessageModel>> _messagesFuture;
  final MessageService _messageService = MessageService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _messagesFuture = _messageService.getMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Iconsax.search_normal, color: AppTheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<MessageModel>>(
        future: _messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load messages',
                style: TextStyle(color: AppTheme.danger),
              ),
            );
          }
          final messages = snapshot.data ?? [];
          if (messages.isEmpty) {
            return Center(
              child: Text(
                'No messages',
                style: TextStyle(color: AppTheme.muted),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _loadMessages(),
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageTile(message: message);
              },
            ),
          );
        },
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final MessageModel message;

  const MessageTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
      child: ListTile(
        leading: Icon(
          _getIconForType(message.type),
          color: message.isRead ? AppTheme.muted : AppTheme.primary,
        ),
        title: Text(
          message.subject,
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(color: AppTheme.muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              DateFormat.yMd().format(message.createdAt),
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          if (!message.isRead) {
            MessageService().markAsRead(message.id);
          }
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'announcement':
        return Iconsax.calendar;
      case 'parent-teacher':
        return Iconsax.device_message;
      case 'admin-staff':
        return Iconsax.message;
      default:
        return Iconsax.message;
    }
  }
}
