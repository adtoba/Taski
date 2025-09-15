import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/providers/messages_provider.dart';
import 'package:taski/core/providers/sessions_provider.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class DualInputWidget extends ConsumerStatefulWidget {
  const DualInputWidget({super.key});

  @override
  ConsumerState<DualInputWidget> createState() => _DualInputWidgetState();
}

enum InputMode { none, text, mic }

class _DualInputWidgetState extends ConsumerState<DualInputWidget> {
  InputMode _mode = InputMode.none;
  final TextEditingController _controller = TextEditingController();
  static const Color primaryColor = Color(0xFF2563EB); // A nice blue
  static const Color borderColor = Color(0xFFE5E7EB); // Light grey

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _mode == InputMode.none
            ? Row(
                key: const ValueKey('buttons'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleButton(
                    icon: Icons.keyboard,
                    onTap: () => setState(() => _mode = InputMode.text),
                    backgroundColor: Colors.white,
                    borderColor: borderColor,
                    iconColor: primaryColor,
                  ),
                  XMargin(20),
                  _CircleButton(
                    icon: Icons.mic,
                    onTap: () => setState(() => _mode = InputMode.mic),
                    backgroundColor: primaryColor,
                    borderColor: Colors.transparent,
                    iconColor: Colors.white,
                  ),
                ],
              )
            : Row(
                key: const ValueKey('input'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_mode == InputMode.text) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(fontSize: 18),
                          onSubmitted: (value) {
                            var messageProvider = ref.read(messagesProvider);
                            messageProvider.sendMessage(
                              sessionId: ref.read(sessionProvider).currentSessionId,
                              content: value,
                              isUser: true,
                              type: 'text',
                            );
                            _controller.clear();
                            setState(() => _mode = InputMode.none);
                          },
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                            filled: true,
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: isDark ? Colors.white : Colors.grey.shade400),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CircleButton(
                      icon: Icons.close,
                      onTap: () => setState(() => _mode = InputMode.none),
                      backgroundColor: Colors.white,
                      borderColor: borderColor,
                      iconColor: primaryColor,
                    ),
                  ] else if (_mode == InputMode.mic) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDEE),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, color: Colors.red, size: 32),
                          const SizedBox(width: 12),
                          Text('Listening...', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CircleButton(
                      icon: Icons.close,
                      onTap: () => setState(() => _mode = InputMode.none),
                      backgroundColor: Colors.white,
                      borderColor: borderColor,
                      iconColor: primaryColor,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.13),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: config.sw(70),
          height: config.sw(70),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 3),
          ),
          child: Center(
            child: Icon(icon, size: 36, color: iconColor),
          ),
        ),
      ),
    );
  }
}