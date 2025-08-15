import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class OnboardingOptionSelector extends StatelessWidget {
  const OnboardingOptionSelector({
    super.key, 
    this.title, 
    this.subtitle, 
    this.isSelected, 
    this.onTap, 
    this.icon,
  });

  final String? title;
  final String? subtitle;
  final bool? isSelected;
  final VoidCallback? onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: config.sw(16), vertical: config.sh(12)),
        decoration: BoxDecoration(
          color: isSelected == true ? Colors.blue.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected == true 
              ? Color(0xff007AFF) 
              : Color(0xffE0E0E0)
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(config.sp(8)),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: icon ?? SizedBox(),
            ),
            XMargin(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? '',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle ?? '', 
                    style: textTheme.bodyMedium?.copyWith(
                      color: Color(0xff6B7688)
                    )
                  ),
                ],
              ),
            ),
            XMargin(10),
            Checkbox(
              value: isSelected,
              onChanged: (value) {},
              activeColor: colorScheme.onPrimary,
              checkColor: colorScheme.onSurface,
              side: BorderSide(
                color: isSelected == true 
                  ? Color(0xff007AFF) 
                  : Color(0xffE0E0E0)
              ),
            ),
          ],
        ),
      ),
    );
  }
}