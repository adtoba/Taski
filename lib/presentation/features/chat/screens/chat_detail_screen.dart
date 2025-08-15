import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/chat/widgets/chat_message_widget.dart';
import 'package:taski/presentation/widgets/dual_input_widget.dart';

class ChatDetailScreen extends StatefulWidget {
  final String query;
  final String response;
  final DateTime timestamp;
  final String type;

  const ChatDetailScreen({
    super.key,
    required this.query,
    required this.response,
    required this.timestamp,
    required this.type,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the original conversation
    _messages.addAll([
      {
        'id': '1',
        'text': widget.query,
        'isUser': true,
        'timestamp': widget.timestamp,
        'type': 'text',
      },
      {
        'id': '2',
        'text': widget.response,
        'isUser': false,
        'timestamp': widget.timestamp.add(Duration(seconds: 30)),
        'type': 'text',
      },
      {
        'id': '3',
        'text': 'Voice message',
        'isUser': true,
        'timestamp': widget.timestamp.add(Duration(minutes: 1)),
        'type': 'voice',
        'duration': '02:12',
      },
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
        'type': 'text',
      });
      _isLoading = true;
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': _generateAIResponse(message),
            'isUser': false,
            'timestamp': DateTime.now(),
            'type': 'text',
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! How can I help you today?';
    } else if (message.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with?';
    } else if (message.contains('embassy') || message.contains('indonesia')) {
      return 'I can help you with information about the Indonesian embassy. What specific information do you need?';
    } else if (message.contains('visa')) {
      return 'For visa information, you\'ll need to check the specific requirements based on your nationality and purpose of visit. Would you like me to help you find the relevant information?';
    } else if (message.contains('contact') || message.contains('phone')) {
      return 'You can contact the embassy at +1-234-567-8900 during their operating hours.';
    } else if (message.contains('hours') || message.contains('time')) {
      return 'The embassy is open Monday to Friday, 9:00 AM to 5:00 PM, excluding holidays.';
    } else {
      return 'I understand you\'re asking about "$userMessage". Let me help you find the most relevant information. Could you provide more details about what you need?';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Chat",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: config.sp(20),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(textTheme)
                  : Container(
                      color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey.shade50,
                      child: ListView.separated(
                        separatorBuilder: (context, index) => YMargin(10),
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: config.sw(16), vertical: config.sh(8)),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isLoading) {
                            return _buildTypingIndicator();
                          }
                          
                          final message = _messages[index];
                          final isLastMessage = index == _messages.length - 1;
                          final showDate = index == 0 || _shouldShowDate(message['timestamp'], _messages[index - 1]['timestamp']);
                          
                          return Column(
                            children: [
                              // if (showDate) _buildDateDivider(message['timestamp']),
                              ChatMessageWidget(
                                text: message['text'],
                                isUser: message['isUser'],
                                timestamp: message['timestamp'],
                                isLastMessage: isLastMessage,
                                messageType: message['type'],
                                duration: message['duration'],
                                onPlayVoice: message['type'] == 'voice' ? () {
                                  // TODO: Implement voice playback
                                  print('Playing voice message: ${message['text']}');
                                } : null,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
            
            // Input Area
            Container(
              padding: EdgeInsets.all(config.sw(16)),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? const Color(0xFF333333) : Colors.grey.shade200, width: 1),
                ),
              ),
              child: DualInputWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Colors.blue.shade600,
            ),
          ),
          YMargin(20),
          Text(
            'Start a conversation',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          YMargin(8),
          Text(
            'Ask me anything and I\'ll help you out',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          YMargin(24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: config.sw(20), vertical: config.sh(12)),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Try asking about embassy information, visa requirements, or contact details',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(left: config.sw(16), top: config.sh(8)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(config.sw(12)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      margin: EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600),
        builder: (context, value, child) {
          return Opacity(
            opacity: (value + index * 0.2) % 1.0,
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildDateDivider(DateTime timestamp) {
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: config.sh(16)),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: config.sw(12), vertical: config.sh(4)),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getDateString(timestamp),
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: config.sp(11),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  bool _shouldShowDate(DateTime current, DateTime previous) {
    final currentDate = DateTime(current.year, current.month, current.day);
    final previousDate = DateTime(previous.year, previous.month, previous.day);
    return !currentDate.isAtSameMomentAs(previousDate);
  }

  String _getDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 