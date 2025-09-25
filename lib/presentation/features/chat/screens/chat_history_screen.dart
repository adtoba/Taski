import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/providers/sessions_provider.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/chat/widgets/chat_history_item_widget.dart';
import 'package:taski/presentation/widgets/dual_input_widget.dart';
import 'package:taski/presentation/features/chat/screens/chat_detail_screen.dart';

import '../../../../domain/models/session.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider).getSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    var isLoading = ref.watch(sessionProvider).isLoadingSessions;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessions = ref.watch(sessionProvider).userSessions;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar( // Ensures no overlay/tint
        elevation: 4,
        scrolledUnderElevation: 4,
        centerTitle: true,
        title: Text(
          "Chat History",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: config.sp(20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Search functionality
              ref.read(sessionProvider).createSession(
                title: "New Session for Testing",
                createdAt: DateTime.now(),
              );
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // TODO: Filter functionality
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with search
          // YMargin(20)
          Container(
            margin: EdgeInsets.symmetric(horizontal: config.sw(20), vertical: config.sh(10)),
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                hintText: "Search conversations...",
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),  
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // TODO: Search functionality
              },
            ),
          ),

          // Chat history list
          Expanded(
            child: isLoading ? Center(child: CircularProgressIndicator()) : sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(config.sw(20)),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        YMargin(16),
                        Text(
                          'No conversations yet',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        YMargin(8),
                        Text(
                          'Start a conversation to see your chat history here',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: config.sw(16)),
                    itemCount: _getGroupedChats().length,
                    itemBuilder: (context, index) {
                      final group = _getGroupedChats()[index];
                      return _buildChatGroup(group['title'], group['chats']);
                    },
                  ),
          ),
          
          // Bottom input widget
          Container(
            padding: EdgeInsets.only(
              left: config.sw(16),
              right: config.sw(16),
              bottom: config.sh(30),
            ),
            child: DualInputWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatGroup(String title, List<Session> chats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YMargin(16),
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: config.sp(12),
          ),
        ),
        YMargin(8),
        ...chats.map((chat) => ChatHistoryItemWidget(
          title: chat.title ?? "",
          timestamp: chat.createdAt ?? DateTime.now(),
          onTap: () {
            ref.read(sessionProvider).setCurrentSessionId(chat.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  query: chat.title ?? "",
                  response: chat.title ?? "",
                  timestamp: chat.createdAt ?? DateTime.now(),
                  type: chat.title ?? "",
                ),
              ),
            );
          },
        )),
      ],
    );
  }

  List<Map<String, dynamic>> _getGroupedChats() {
    var sessions = ref.watch(sessionProvider).userSessions;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final weekAgo = today.subtract(Duration(days: 7));
    
    final todayChats = sessions.where((chat) {
      final chatDate = DateTime(chat.createdAt!.year, chat.createdAt!.month, chat.createdAt!.day);
      return chatDate.isAtSameMomentAs(today);
    }).toList();
    
    final yesterdayChats = sessions.where((chat) {
      final chatDate = DateTime(chat.createdAt!.year, chat.createdAt!.month, chat.createdAt!.day);
      return chatDate.isAtSameMomentAs(yesterday);
    }).toList();
    
    final olderChats = sessions.where((chat) {
      final chatDate = DateTime(chat.createdAt!.year, chat.createdAt!.month, chat.createdAt!.day);
      return chatDate.isBefore(yesterday);
    }).toList();
    
    List<Map<String, dynamic>> groups = [];
    
    if (todayChats.isNotEmpty) {
      groups.add({'title': 'Today', 'chats': todayChats});
    }
    if (yesterdayChats.isNotEmpty) {
      groups.add({'title': 'Yesterday', 'chats': yesterdayChats});
    }
    if (olderChats.isNotEmpty) {
      groups.add({'title': 'Previous 7 Days', 'chats': olderChats});
    }
    
    return groups;
  }
} 