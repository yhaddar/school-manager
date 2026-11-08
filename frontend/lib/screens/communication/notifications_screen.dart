import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Notifications'),
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
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load notifications',
                style: TextStyle(color: AppTheme.danger),
              ),
            );
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications',
                style: TextStyle(color: AppTheme.muted),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _loadNotifications(),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
      child: ListTile(
        leading: Icon(
          _getIconForType(notification.type),
          color: notification.isRead ? AppTheme.muted : AppTheme.primary,
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(color: AppTheme.muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              DateFormat.yMd().format(notification.createdAt),
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ],
        ),
        trailing: notification.priority == 'urgent'
            ? Icon(Iconsax.warning_2, color: Colors.orange, size: 20)
            : null,
        onTap: () {
          if (!notification.isRead) {
            NotificationService().markAsRead(notification.id);
          }
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'announcement':
        return Iconsax.info_circle;
      case 'reminder':
        return Iconsax.alarm;
      case 'warning':
        return Iconsax.warning_2;
      case 'system':
        return Iconsax.settings;
      default:
        return Iconsax.calendar;
    }
  }
}
