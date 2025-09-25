import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/providers/audio_recorder_provider.dart';
import 'package:taski/core/providers/messages_provider.dart';
import 'package:taski/core/providers/sessions_provider.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/chat/widgets/chat_message_widget.dart';
import 'package:taski/presentation/widgets/dual_input_widget.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {

  @override
  void initState() {
    super.initState();
    // Initialize with the original conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var currentSessionId = ref.read(sessionProvider).currentSessionId;
      if (currentSessionId != null) {
        ref.read(messagesProvider).getMessages(sessionId: currentSessionId);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isFetchingMessages = ref.watch(messagesProvider).isFetchingMessages;
    final isLoading = ref.watch(messagesProvider).isCompleteLoading;
    var messages = ref.watch(messagesProvider).userMessages;
    final scrollController = ref.watch(messagesProvider).scrollController;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    
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
              child: isFetchingMessages ? _buildLoadingState() : messages.isEmpty
                  ? _buildEmptyState(textTheme)
                  : Container(
                      color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey.shade50,
                      child: ListView.separated(
                        separatorBuilder: (context, index) => YMargin(10),
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: config.sw(16), vertical: config.sh(8)),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && isLoading) {
                            return _buildTypingIndicator();
                          } 
                          final message = messages[index];
                          return Column(
                            children: [
                              // if (showDate) _buildDateDivider(message.createdAt!),
                              ChatMessageWidget(
                                text: message.content ?? '',
                                isUser: message.isUser ?? false,
                                timestamp: DateTime.now(),
                                messageType: message.type ?? '',
                                duration: '',
                                onPlayVoice: message.type == 'audio' ? () {
                                  audioRecorderProvider.playAudio(
                                    url: message.content,
                                    path: message.path ?? '',
                                  );
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

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
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