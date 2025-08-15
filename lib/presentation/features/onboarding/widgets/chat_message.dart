import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: config.sh(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Bot avatar
            Container(
              width: config.sw(32),
              height: config.sh(32),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: config.sp(18),
              ),
            ),
            XMargin(12),
          ],
          
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: config.sw(16),
                    vertical: config.sh(12),
                  ),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? colorScheme.primary 
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomLeft: isUser ? Radius.circular(18) : Radius.circular(4),
                      bottomRight: isUser ? Radius.circular(4) : Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    text,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: config.sp(14),
                      fontWeight: FontWeight.w400,
                      color: isUser 
                          ? colorScheme.onPrimary 
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                YMargin(4),
                Text(
                  _formatTime(timestamp),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: config.sp(11),
                    color: colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          if (isUser) ...[
            XMargin(12),
            // User avatar
            Container(
              width: config.sw(32),
              height: config.sh(32),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: config.sp(18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
} 