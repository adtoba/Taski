import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class OptionSelector extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onSelectionChanged;

  const OptionSelector({
    super.key,
    required this.options,
    required this.onSelectionChanged,
  });

  @override
  State<OptionSelector> createState() => _OptionSelectorState();
}

class _OptionSelectorState extends State<OptionSelector> with TickerProviderStateMixin {
  final Set<String> _selectedOptions = {};
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
    
    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Notify parent
    widget.onSelectionChanged(_selectedOptions.toList());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: config.sh(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            margin: EdgeInsets.only(bottom: config.sh(16)),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: colorScheme.primary,
                  size: config.sp(20),
                ),
                XMargin(8),
                Text(
                  "Select your preferences",
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: config.sp(16),
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
                Spacer(),
                if (_selectedOptions.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: config.sw(8),
                      vertical: config.sh(4),
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_selectedOptions.length} selected",
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: config.sp(12),
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Options grid
          Wrap(
            spacing: config.sw(8),
            runSpacing: config.sh(8),
            children: widget.options.map((option) {
              final isSelected = _selectedOptions.contains(option);
              
              return AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: GestureDetector(
                      onTap: () => _toggleOption(option),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: config.sw(16),
                          vertical: config.sh(12),
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? colorScheme.primary 
                              : colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? colorScheme.primary 
                                : colorScheme.outline.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              child: Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                size: config.sp(18),
                                color: isSelected 
                                    ? colorScheme.onPrimary 
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            XMargin(8),
                            Flexible(
                              child: Text(
                                option,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: config.sp(14),
                                  fontWeight: FontWeight.w500,
                                  color: isSelected 
                                      ? colorScheme.onPrimary 
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          
          // Continue button
          if (_selectedOptions.isNotEmpty) ...[
            YMargin(24),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // The selection is already handled by onSelectionChanged
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: config.sh(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue",
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: config.sp(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    XMargin(8),
                    Icon(
                      Icons.arrow_forward,
                      size: config.sp(18),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Helper text
          if (_selectedOptions.isEmpty) ...[
            YMargin(16),
            Container(
              padding: EdgeInsets.all(config.sw(12)),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: config.sp(16),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  XMargin(8),
                  Expanded(
                    child: Text(
                      "Select at least one option to continue",
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: config.sp(12),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 