import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:taski/core/services/google_calendar_service.dart';
import 'package:taski/presentation/features/calendar/widgets/calendar_day_widget.dart';
  
class CalendarProvider extends ChangeNotifier {

  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();

  void setFocusedDate(DateTime date) {
    focusedDate = date;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  List<Event> events = [];
  bool isLoadingEvents = false;

  List<Event> upcomingEvents = [];

  Future<List<Event>> getUpcomingEvents() async {
    isLoadingEvents = true;
    notifyListeners();

    try {
      final calendarEvents = await GoogleCalendarService.instance.listEvents();
      var events = calendarEvents.items?.where(
        (event) => event.start?.dateTime != null && event.start!.dateTime!.isAfter(DateTime.now())
      ).toList();

      upcomingEvents = events ?? [];
      return upcomingEvents;
    } catch (e) {
      log(e.toString());
      return [];
    } finally {
      isLoadingEvents = false;
      notifyListeners();
    }
  }

  Future<void> listEvents() async {
    isLoadingEvents = true;
    notifyListeners();

    try {
      final calendarEvents = await GoogleCalendarService.instance.listEvents();
      events = calendarEvents.items ?? [];

      for(var event in events) {
        log(event.summary ?? "");
      }

      isLoadingEvents = false;
      notifyListeners();
    } catch (e) {
      isLoadingEvents = false;
      notifyListeners();
      log(e.toString());
    }
  }

  Widget buildCalendarGrid() {

    final daysInMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    List<Widget> dayWidgets = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday - 1; i++) {
      dayWidgets.add(Expanded(child: SizedBox()));
    }
    
    // Add day cells for the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedDate.year, focusedDate.month, day);
      final isSelected = _isSameDay(date, selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final hasEvents = getEventsForDate(date).isNotEmpty;
      
      dayWidgets.add(
        Expanded(
          child: CalendarDayWidget(
            day: day,
            isSelected: isSelected,
            isToday: isToday,
            hasEvents: hasEvents,
            onTap: () {
              selectedDate = date;
              notifyListeners();
            },
          ),
        ),
      );
    }
    
    // Create rows of 7 days each
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final rowDays = dayWidgets.skip(i).take(7).toList();
      // Pad with empty cells if needed
      while (rowDays.length < 7) {
        rowDays.add(Expanded(child: SizedBox()));
      }
      rows.add(Row(children: rowDays));
    }
    
    return Column(children: rows);
  }

  List<Event> getEventsForDate(DateTime date) {
    final filteredEvents = events.where((event) => event.start?.dateTime != null).toList();
    return filteredEvents.where((event) => _isSameDay(event.start!.dateTime!, date)).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String getMonthYearString(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String getDateString(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

final calendarProvider = ChangeNotifierProvider<CalendarProvider>((ref) {
  return CalendarProvider();
});