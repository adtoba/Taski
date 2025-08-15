import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class EventWidget extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final String duration;
  final Color color;
  final VoidCallback onTap;

  const EventWidget({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.duration,
    required this.color,
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
          padding: EdgeInsets.all(config.sw(16)),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
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
              // Color indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              XMargin(12),
              
              // Event content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: config.sp(14),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        XMargin(8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            time,
                            style: textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: config.sp(11),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    YMargin(4),
                    
                    // Description
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                        fontSize: config.sp(12),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    YMargin(4),
                    
                    // Duration
                    Text(
                      duration,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: config.sp(11),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 