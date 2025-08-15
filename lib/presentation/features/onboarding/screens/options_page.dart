import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {

  final List<Map<String, dynamic>> _options = [
    {
      'title': 'Calendar',
      'subtitle': 'Manage your appointments, schedule, and events with ease.',
      'type': 'calendar',
      'icon': Icons.calendar_month,
      'color': Color(0xFF6366F1),
      'gradient': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    },
    {
      'title': 'Communication',
      'subtitle': 'Send, receive, and manage texts and emails — all in one place.',
      'type': 'communication',
      'icon': Icons.chat_bubble_outline,
      'color': Color(0xFFF59E0B),
      'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
    },
    {
      'title': 'To-Do List',
      'subtitle': 'Stay on top of daily tasks and check things off as you go.',
      'type': 'tasks',
      'icon': Icons.check_circle_outline,
      'color': Color(0xFF10B981),
      'gradient': [Color(0xFF10B981), Color(0xFF059669)],
    },
    {
      'title': 'All of the Above',
      'subtitle': 'Taski handles your tasks, time, and talk — seamlessly.',
      'type': 'all',
      'icon': Icons.all_inclusive,
      'color': Color(0xFF8B5CF6),
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    }
  ];

  final List<String> _selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YMargin(10),
          Text(
            "How can i help you",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: config.sp(25),
            ),
          ),
          YMargin(5),
          Text(
            "Choose one or more options",
            style: textTheme.bodyMedium?.copyWith(
              fontSize: config.sp(16),
            ),
          ),
          YMargin(20),
          Wrap(
            spacing: config.sw(10),
            runSpacing: config.sh(10),
            children: _options.map((option) {
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    if (_selectedOptions.contains(option['type'])) {
                      _selectedOptions.remove(option['type']);
                    } else {
                      _selectedOptions.add(option['type']);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: config.sw(10), vertical: config.sh(10)),
                  decoration: BoxDecoration(
                    color:Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedOptions.contains(option['type']) ? option['gradient'][0] : Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(option['icon'], color: option['color']),
                      XMargin(10),
                      Text(option['title'], style: textTheme.bodyMedium?.copyWith(
                        fontSize: config.sp(16),
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),            
        ],
      ),
    );
  }
}