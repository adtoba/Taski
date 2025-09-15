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
  // Sample chat history data
  // final List<Map<String, dynamic>> _chatHistory = [
  //   {
  //     'id': '1',
  //     'query': 'Direction to embassy of Indonesia',
  //     'response': 'The embassy is located at 123 Main Street...',
  //     'timestamp': DateTime.now().subtract(Duration(hours: 2)),
  //     'type': 'location',
  //     'isFavorite': false,
  //   },
  //   {
  //     'id': '2',
  //     'query': 'Contact number for the embassy of Indonesia',
  //     'response': 'You can reach them at +1-234-567-8900...',
  //     'timestamp': DateTime.now().subtract(Duration(hours: 4)),
  //     'type': 'contact',
  //     'isFavorite': true,
  //   },
  //   {
  //     'id': '3',
  //     'query': 'Operating hours of the embassy of Indonesia',
  //     'response': 'The embassy is open Monday to Friday, 9 AM to 5 PM...',
  //     'timestamp': DateTime.now().subtract(Duration(days: 1)),
  //     'type': 'hours',
  //     'isFavorite': false,
  //   },
  //   {
  //     'id': '4',
  //     'query': 'Website link for the embassy of Indonesia',
  //     'response': 'You can visit their official website at...',
  //     'timestamp': DateTime.now().subtract(Duration(days: 1, hours: 3)),
  //     'type': 'website',
  //     'isFavorite': false,
  //   },
  //   {
  //     'id': '5',
  //     'query': 'Email address for the embassy of Indonesia',
  //     'response': 'You can email them at embassy@indonesia.gov...',
  //     'timestamp': DateTime.now().subtract(Duration(days: 2)),
  //     'type': 'contact',
  //     'isFavorite': true,
  //   },
  //   {
  //     'id': '6',
  //     'query': 'Location of the embassy of Indonesia',
  //     'response': 'The embassy is situated in the downtown area...',
  //     'timestamp': DateTime.now().subtract(Duration(days: 3)),
  //     'type': 'location',
  //     'isFavorite': false,
  //   },
  //   {
  //     'id': '7',
  //     'query': 'Visa requirements for Indonesia',
  //     'response': 'For tourist visas, you need a valid passport...',
  //     'timestamp': DateTime.now().subtract(Duration(days: 5)),
  //     'type': 'visa',
  //     'isFavorite': true,
  //   },
  //   {
  //     'id': '8',
  //     'query': 'Document requirements for visa application',
  //     'response': 'You will need to provide the following documents...',
  //     'timestamp': DateTime.now().subtract(Duration(days: 6)),
  //     'type': 'documents',
  //     'isFavorite': false,
  //   },
  // ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider).getSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // YMargin(20),
        //  Container(
        //     padding: EdgeInsets.symmetric(horizontal: config.sw(16), vertical: config.sh(12)),
        //     margin: EdgeInsets.symmetric(horizontal: config.sw(20)),
        //     decoration: BoxDecoration(
        //       color: Colors.grey.shade50,
        //       borderRadius: BorderRadius.circular(12),
        //       border: Border.all(color: Colors.grey.shade200),
        //     ),
        //     child: Row(
        //       children: [
        //         Icon(Icons.search, color: Colors.grey.shade500, size: 20),
        //         XMargin(8),
        //         Expanded(
        //           child: Text(
        //             'Search conversations...',
        //             style: textTheme.bodyMedium?.copyWith(
        //               color: Colors.grey.shade500,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
          
          // Chat history list
          Expanded(
            child: sessions.isEmpty
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