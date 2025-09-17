import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLastMessage;
  final String? messageType; // 'text' or 'voice'
  final String? duration; // for voice messages
  final VoidCallback? onPlayVoice; // callback for voice playback

  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLastMessage = false,
    this.messageType = 'text',
    this.duration,
    this.onPlayVoice,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          XMargin(12),
        ],
        
        // Message bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: config.sw(16),
              vertical: config.sh(12),
            ),
            decoration: BoxDecoration(
              color: isUser 
                  ? Colors.blue.shade500 
                  : isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isUser 
                      ? Colors.blue.shade200.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
              border: isUser 
                  ? null 
                  : Border.all(
                      color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
                      width: 1,
                    ),
            ),
            child: messageType == 'voice' 
                ? _buildVoiceMessage(textTheme)
                : _buildTextMessage(textTheme, context),
          ),
        ),
        
        if (isUser) ...[
          XMargin(12),
          // User Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextMessage(TextTheme textTheme, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message text
        SelectableText(
          text,
          style: textTheme.bodyMedium?.copyWith(
            color: isUser ? Colors.white : isDark ? Colors.white : Colors.black87,
            fontSize: config.sp(14),
            height: 1.4,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        
        YMargin(6),
        
        // Timestamp
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            _getTimeString(timestamp),
            style: textTheme.bodySmall?.copyWith(
              color: isUser 
                  ? Colors.white.withOpacity(0.8) 
                  : Colors.grey.shade500,
              fontSize: config.sp(11),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceMessage(TextTheme textTheme) {
    return Row(
      children: [
        // Play button
        GestureDetector(
          onTap: onPlayVoice,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isUser 
                  ? Colors.white.withOpacity(0.2) 
                  : Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: isUser ? Colors.white : Colors.blue.shade600,
              size: 20,
            ),
          ),
        ),
        
        XMargin(12),
        
        // Waveform
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Waveform bars
              Row(
                children: List.generate(20, (index) {
                  final height = 2 + (index % 3) * 4.0;
                  return Container(
                    width: 2,
                    height: height,
                    margin: EdgeInsets.only(right: 1),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? Colors.white.withOpacity(0.7) 
                          : Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                }),
              ),
              
              YMargin(4),
              
              // Duration
              Text(
                duration ?? '0:00',
                style: textTheme.bodySmall?.copyWith(
                  color: isUser 
                      ? Colors.white.withOpacity(0.8) 
                      : Colors.grey.shade600,
                  fontSize: config.sp(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        XMargin(8),
        
        // Timestamp
        Text(
          _getTimeString(timestamp),
          style: textTheme.bodySmall?.copyWith(
            color: isUser 
                ? Colors.white.withOpacity(0.8) 
                : Colors.grey.shade500,
            fontSize: config.sp(11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getTimeString(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
} 