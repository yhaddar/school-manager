import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../services/calendar_service.dart';
import '../../models/calendar_event_model.dart';

class CalendarEventsScreen extends StatefulWidget {
  const CalendarEventsScreen({super.key});

  @override
  State<CalendarEventsScreen> createState() => _CalendarEventsScreenState();
}

class _CalendarEventsScreenState extends State<CalendarEventsScreen> {
  late Future<List<CalendarEventModel>> _eventsFuture;
  final CalendarService _calendarService = CalendarService();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = _calendarService.getCalendarEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Iconsax.calendar, color: AppTheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<CalendarEventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load calendar events',
                style: TextStyle(color: AppTheme.danger),
              ),
            );
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(
              child: Text(
                'No calendar events',
                style: TextStyle(color: AppTheme.muted),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _loadEvents(),
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return CalendarEventTile(event: event);
              },
            ),
          );
        },
      ),
    );
  }
}

class CalendarEventTile extends StatelessWidget {
  final CalendarEventModel event;

  const CalendarEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
      child: ListTile(
        leading: Icon(
          _getIconForType(event.type),
          color: AppTheme.primary,
        ),
        title: Text(
          event.title,
          style: TextStyle(color: AppTheme.onSurface),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description ?? '',
              style: TextStyle(color: AppTheme.muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              '${DateFormat.yMd().format(event.startsAt)} - ${DateFormat.jm().format(event.startsAt)}',
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ],
        ),
        trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
        onTap: () {
          Get.toNamed('/calendar/event/${event.id}');
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'holiday':
        return Iconsax.calendar;
      case 'exam':
        return Iconsax.clipboard_tick;
      case 'sports':
        return Iconsax.activity;
      case 'cultural':
        return Iconsax.document;
      case 'assembly':
        return Iconsax.user_square;
      default:
        return Iconsax.calendar;
    }
  }
}
