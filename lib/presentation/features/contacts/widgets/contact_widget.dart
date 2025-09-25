import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class ContactWidget extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final VoidCallback onTap;

  const ContactWidget({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
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
              Icon(
                Icons.person,
                color: Colors.grey.shade400,
                size: 20,
              ),
              XMargin(12),              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Query
                    Text(
                      name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: config.sp(14),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
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
} 