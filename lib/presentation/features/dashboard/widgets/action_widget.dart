import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({super.key, this.title, this.icon, this.iconColor, this.onTap});

  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: config.sw(10), vertical: config.sh(10)),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF333333) : Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor ?? Colors.black87),
            XMargin(10),
            Text(
              title ?? "", 
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: config.sp(14),
              )
            ),
          ],
        ),
      ),
    );
  }
}