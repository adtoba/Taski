import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onSubmitted;
  final bool isTyping;

  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    this.isTyping = false,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isFocused 
              ? colorScheme.surface 
              : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isFocused 
                ? colorScheme.primary 
                : colorScheme.outline.withOpacity(0.2),
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused ? [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: TextField(
          controller: widget.controller,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: config.sp(14),
            color: colorScheme.onBackground,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: textTheme.bodyMedium?.copyWith(
              fontSize: config.sp(14),
              color: colorScheme.onBackground.withOpacity(0.5),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: config.sw(16),
              vertical: config.sh(12),
            ),
            suffixIcon: widget.isTyping
                ? Container(
                    margin: EdgeInsets.only(right: config.sw(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingIndicator(),
                        XMargin(8),
                        Container(
                          padding: EdgeInsets.all(config.sw(4)),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: config.sp(16),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          onSubmitted: widget.onSubmitted,
          textInputAction: TextInputAction.send,
          maxLines: null,
          minLines: 1,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        _buildDot(1),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: config.sw(4),
          height: config.sw(4),
          margin: EdgeInsets.symmetric(horizontal: config.sw(1)),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(
              0.3 + (0.7 * (value * (index + 1) / 3)),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
} 