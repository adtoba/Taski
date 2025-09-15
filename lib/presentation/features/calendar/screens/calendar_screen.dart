import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taski/core/providers/calendar_provider.dart';
import 'package:taski/core/utils/navigator.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/calendar/widgets/calendar_day_widget.dart';
import 'package:taski/presentation/features/calendar/widgets/event_widget.dart';
import 'package:taski/presentation/features/calendar/screens/event_detail_screen.dart';
import 'package:taski/presentation/widgets/dual_input_widget.dart';
import 'dart:math' as math;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  double _lastSheetSize = 0.36;
  double? _dragStartSheetSize;
  double? _dragStartGlobalY;

  @override
  void initState() {
    super.initState();
    ref.read(calendarProvider.notifier).listEvents();
  }


  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    var focusedDate = calendarState.focusedDate;
    var selectedDate = calendarState.selectedDate;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Stack(
        children: [
          // Calendar Header and Month View
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Calendar Header
              Container(
                // color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: config.sw(16), vertical: config.sh(12)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        calendarState.setFocusedDate(DateTime(focusedDate.year, focusedDate.month - 1));
                      },
                      icon: Icon(Icons.chevron_left, color: Colors.grey.shade600),
                    ),
                    Expanded(
                      child: Text(
                        calendarState.getMonthYearString(focusedDate),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: config.sp(20),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        calendarState.setFocusedDate(DateTime(focusedDate.year, focusedDate.month + 1));
                      },
                      icon: Icon(Icons.chevron_right, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              // Calendar Grid
              Container(
                // color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: config.sw(16)),
                child: Column(
                  children: [
                    // Day headers
                    Row(
                      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                          .map((day) => Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: config.sh(12)),
                                  child: Text(
                                    day,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                      fontSize: config.sp(12),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    // Calendar days
                    calendarState.buildCalendarGrid(),
                  ],
                ),
              ),
            ],
          ),
          // Draggable Events Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.42, // About 2.5 events visible
            minChildSize: 0.42, // Just the handle and header
            maxChildSize: calendarState.getEventsForDate(selectedDate).isEmpty ? 0.42 : 0.82, // Just under the month/year header
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                  // Drag handle (always draggable)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragStart: (details) {
                        if (_sheetController.isAttached) {
                          _dragStartSheetSize = _sheetController.size;
                          _dragStartGlobalY = details.globalPosition.dy;
                        }
                      },
                      onVerticalDragUpdate: (details) {
                        if (_dragStartSheetSize != null && _dragStartGlobalY != null && _sheetController.isAttached) {
                          final dragDelta = details.globalPosition.dy - _dragStartGlobalY!;
                          final screenHeight = MediaQuery.of(context).size.height;
                          final minSize = 0.18;
                          final maxSize = 0.82;
                          double newSize = _dragStartSheetSize! - dragDelta / screenHeight;
                          newSize = math.max(minSize, math.min(maxSize, newSize));
                          _sheetController.jumpTo(newSize);
                        }
                      },
                      onVerticalDragEnd: (details) {
                        _dragStartSheetSize = null;
                        _dragStartGlobalY = null;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 8),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Events header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: config.sw(16)),
                      child: Row(
                        children: [
                          Text(
                            'Events for ${calendarState.getDateString(selectedDate)}',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: config.sp(16),
                            ),
                          ),
                          Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: Navigate to add event
                            },
                            icon: Icon(Icons.add, size: 18),
                            label: Text('Add Event'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    YMargin(8),
                    // Events list or empty state
                    Expanded(
                      child: calendarState.getEventsForDate(selectedDate).isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_note,
                                    size: 64,
                                    color: isDark ? Colors.white : Colors.grey.shade400,
                                  ),
                                  Text(
                                    'No events scheduled',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: isDark ? Colors.white : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(horizontal: config.sw(16)),
                              itemCount: calendarState.getEventsForDate(selectedDate).length,
                              itemBuilder: (context, index) {
                                final event = calendarState.getEventsForDate(selectedDate)[index];
                                final startTimeText = event.start?.dateTime != null ? DateFormat('h:mm a').format(event.start?.dateTime ?? DateTime.now()) : "All day";
                                final startTime = event.start?.dateTime;
                                final endTime = event.end?.dateTime;
                                // Calculate duration
                                String durationText = "";
                                if (startTime != null && endTime != null) {
                                  final duration = endTime.difference(startTime);
                                  if (duration.inMinutes < 60) {
                                    durationText = "${duration.inMinutes} minutes";
                                  } else if (duration.inHours < 24) {
                                    durationText = "${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}";
                                  } else {
                                    durationText = "${duration.inDays} day${duration.inDays > 1 ? 's' : ''}";
                                  }
                                }
                                return EventWidget(
                                  title: event.summary ?? "",
                                  description: event.description ?? "No description",
                                  time: startTimeText,
                                  duration: event.end?.dateTime != null && event.start?.dateTime != null ? durationText : "All day",
                                  color: Colors.blue,
                                  onTap: () {
                                    push(EventDetailScreen(event: event));
                                  },
                                );
                              },
                            ),
                    ),
                    // Bottom input widget
                    Padding(
                      padding: EdgeInsets.only(
                        left: config.sw(16),
                        right: config.sw(16),
                        bottom: MediaQuery.of(context).padding.bottom + 8,
                        top: 8,
                      ),
                      child: DualInputWidget(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 