import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class CalendarDayWidget extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool hasEvents;
  final VoidCallback onTap;

  const CalendarDayWidget({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasEvents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: config.sh(40),
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.blue.shade600 
                : isToday 
                    ? Colors.blue.shade50 
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday && !isSelected
                ? Border.all(color: Colors.blue.shade300, width: 1)
                : null,
          ),
          child: Stack(
            children: [
              // Day number
              Center(
                child: Text(
                  day.toString(),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? Colors.white 
                        : isToday 
                            ? Colors.blue.shade700 
                            : isDark ? Colors.white : Colors.black87,
                    fontSize: config.sp(14),
                  ),
                ),
              ),
              
              // Event indicator
              if (hasEvents)
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white 
                            : Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 