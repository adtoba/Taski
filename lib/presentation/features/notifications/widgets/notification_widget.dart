import 'package:flutter/material.dart';
import 'package:taski/main.dart';

class NotificationWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final String type;
  final VoidCallback? onTap;

  const NotificationWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(config.sw(12)),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(type),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: _getIconColor(type),
                  size: 18,
                ),
              ),
              
              SizedBox(width: config.sw(10)),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: config.sp(12),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: config.sh(2)),
                    
                    // Body
                    Text(
                      body,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case 'task':
        return Colors.green.shade50;
      case 'calendar':
        return Colors.blue.shade50;
      case 'message':
        return Colors.purple.shade50;
      case 'event':
        return Colors.orange.shade50;
      case 'system':
        return Colors.red.shade50;
      case 'warning':
        return Colors.amber.shade50;
      case 'info':
        return Colors.cyan.shade50;
      case 'success':
        return Colors.teal.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'task':
        return Colors.green.shade600;
      case 'calendar':
        return Colors.blue.shade600;
      case 'message':
        return Colors.purple.shade600;
      case 'event':
        return Colors.orange.shade600;
      case 'system':
        return Colors.red.shade600;
      case 'warning':
        return Colors.amber.shade600;
      case 'info':
        return Colors.cyan.shade600;
      case 'success':
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
} 