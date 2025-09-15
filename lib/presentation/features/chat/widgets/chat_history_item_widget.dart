import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class ChatHistoryItemWidget extends StatelessWidget {
  final String title;
  final DateTime timestamp;
  final VoidCallback onTap;

  const ChatHistoryItemWidget({
    super.key,
    required this.title,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {  
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.only(bottom: config.sh(8)),
          padding: EdgeInsets.all(config.sw(12)),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Type indicator
              // Container(
              //   width: 40,
              //   height: 40,
              //   decoration: BoxDecoration(
              //     color: _getTypeColor(type).withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: Icon(
              //     _getTypeIcon(type),
              //     color: _getTypeColor(type),
              //     size: 20,
              //   ),
              // ),
              
              XMargin(12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Query
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: config.sp(14),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // YMargin(4),
                    
                    // // Response preview
                    // Text(
                    //   response,
                    //   style: textTheme.bodySmall?.copyWith(
                    //     color: Colors.grey.shade600,
                    //     fontSize: config.sp(12),
                    //   ),
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    
                    // YMargin(4),
                    
                    // Timestamp
                    Text(
                      _getTimeAgo(timestamp),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: config.sp(11),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  // Favorite button
                  // IconButton(
                  //   onPressed: onFavorite,
                  //   icon: Icon(
                  //     isFavorite ? Icons.favorite : Icons.favorite_border,
                  //     color: isFavorite ? Colors.red.shade500 : Colors.grey.shade400,
                  //     size: 20,
                  //   ),
                  //   padding: EdgeInsets.zero,
                  //   constraints: BoxConstraints(
                  //     minWidth: 32,
                  //     minHeight: 32,
                  //   ),
                  // ),
                  
                  // Chevron
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'location':
        return Colors.blue;
      case 'contact':
        return Colors.green;
      case 'hours':
        return Colors.orange;
      case 'website':
        return Colors.purple;
      case 'visa':
        return Colors.red;
      case 'documents':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'location':
        return Icons.location_on;
      case 'contact':
        return Icons.phone;
      case 'hours':
        return Icons.access_time;
      case 'website':
        return Icons.language;
      case 'visa':
        return Icons.assignment;
      case 'documents':
        return Icons.description;
      default:
        return Icons.chat_bubble;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      if(difference.inMinutes == 0) {
        return 'Just now';
      }
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 