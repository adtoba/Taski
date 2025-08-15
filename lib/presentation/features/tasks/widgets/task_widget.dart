import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taski/core/providers/tasks_provider.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

import 'package:timeago/timeago.dart' as timeago;


class TaskWidget extends ConsumerWidget {
  final String description;
  final String scheduledTime;
  final bool isCompleted;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;
  final VoidCallback? onTap;

  const TaskWidget({
    super.key,
    required this.description,
    required this.scheduledTime,
    required this.isCompleted,
    this.isSelected = false,
    this.onSelectionToggle,
    this.onTap,
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final taskState = ref.watch(tasksProvider);
    
    // Determine color based on completion status
    final Color taskColor = isCompleted ? Colors.green : Colors.blue;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.only(bottom: config.sh(8)),
          padding: EdgeInsets.all(config.sw(16)),
          decoration: BoxDecoration(
            color: isSelected ? taskColor.withOpacity(0.05) : isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? taskColor.withOpacity(0.3) 
                  : taskColor.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Selection/Completion indicator
                  GestureDetector(
                    onTap: onSelectionToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? Colors.green.shade500 
                            : isSelected 
                                ? taskColor 
                                : Colors.transparent,
                        border: Border.all(
                          color: isCompleted 
                              ? Colors.green.shade500 
                              : isSelected 
                                  ? taskColor 
                                  : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isCompleted || isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  
                  XMargin(12),
                  
                  // Task content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task description
                        Text(
                          description,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isCompleted 
                                ? Colors.grey.shade600 
                                : isSelected 
                                    ? taskColor 
                                    : isDark ? Colors.white : Colors.black87,
                            fontSize: config.sp(14),
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.grey.shade400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        YMargin(4),
                      
                      ],
                    ),
                  ),
                  
                  // Status badge for completed tasks
                  if (isCompleted)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Completed',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: config.sp(11),
                        ),
                      ),
                    ),
                  
                  // Chevron for navigation
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                ],
              ),

              // Scheduled time with enhanced formatting
              YMargin(10),
              Row(
                children: [
                  Text(
                    taskState.formatDateTime(scheduledTime, scheduledTime),
                    style: textTheme.bodySmall?.copyWith(
                      color: isCompleted 
                          ? Colors.grey.shade500 
                          : isSelected 
                              ? taskColor 
                              : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: config.sp(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 