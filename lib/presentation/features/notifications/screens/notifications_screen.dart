import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/notifications/widgets/notification_widget.dart';
import 'package:taski/presentation/widgets/dual_input_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.task_alt,
      'title': 'Task Completed',
      'body': 'Your task "Design Sprint Planning" has been completed successfully.',
      'time': '2 min ago',
      'type': 'task',
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Meeting Reminder',
      'body': 'You have a team meeting in 15 minutes. Don\'t forget to prepare your updates.',
      'time': '15 min ago',
      'type': 'calendar',
    },
    {
      'icon': Icons.message,
      'title': 'New Message',
      'body': 'Sarah sent you a message about the project timeline.',
      'time': '1 hour ago',
      'type': 'message',
    },
    {
      'icon': Icons.notifications,
      'title': 'System Update',
      'body': 'Your app has been updated to version 2.1.0 with new features.',
      'time': '2 hours ago',
      'type': 'system',
    },
    {
      'icon': Icons.event,
      'title': 'Event Reminder',
      'body': 'Your calendar event "Client Presentation" starts in 30 minutes.',
      'time': '3 hours ago',
      'type': 'event',
    },
    {
      'icon': Icons.task_alt,
      'title': 'Task Completed',
      'body': 'Your task "Design Sprint Planning" has been completed successfully.',
      'time': '2 min ago',
      'type': 'task',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Notifications",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: config.sp(20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
            },
            child: Text(
              "Clear All",
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: isDark ? Colors.white : Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No notifications",
                        style: textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "You're all caught up!",
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (context, index) => YMargin(10),
                  padding: EdgeInsets.only(bottom: config.sh(100), top: config.sh(10), left: config.sw(12), right: config.sw(12)),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return NotificationWidget(
                      icon: notification['icon'],
                      title: notification['title'],
                      body: notification['body'],
                      time: notification['time'],
                      type: notification['type'],
                      onTap: () {
                        // Handle notification tap if needed
                      },
                    );
                  },
                ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: DualInputWidget(),
          ),
        ],
      ),
    );
  }
}