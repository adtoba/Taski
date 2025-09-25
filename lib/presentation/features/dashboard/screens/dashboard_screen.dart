import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taski/core/providers/calendar_provider.dart';
import 'package:taski/core/services/google_calendar_service.dart';
import 'package:taski/core/services/supabase_service.dart';
import 'package:taski/core/utils/navigator.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/calendar/screens/calendar_screen.dart';
import 'package:taski/presentation/features/calendar/screens/event_detail_screen.dart';
import 'package:taski/presentation/features/dashboard/widgets/action_widget.dart';
import 'package:taski/presentation/features/dashboard/widgets/upcoming_widget.dart';
import 'package:taski/presentation/widgets/base_screen.dart';
import 'package:taski/presentation/widgets/dual_input_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onPageChange;
  
  const DashboardScreen({super.key, this.onPageChange});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(calendarProvider.notifier).getUpcomingEvents();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BaseScreen(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: config.sw(20), vertical: config.sh(20)),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    children: [
                      Text(
                        "Your Upcoming Events",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: config.sp(20), // Slightly larger
                        ),
                        semanticsLabel: "Your Next Events",
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          widget.onPageChange?.call(1);
                        },
                        borderRadius: BorderRadius.circular(6),
                        splashColor: Colors.blue.withOpacity(0.1), // Subtle splash
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            "View All",
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: config.sp(14), // Slightly larger
                              color: Colors.blue[700], // More visible
                            ),
                            semanticsLabel: "View all events and reminders",
                          ),
                        ),
                      ),
                    ],
                  ),
                  YMargin(10), // More space after title
                  // Upcoming Events List or Empty State
                  _upcomingEventsList(),
                  YMargin(30),
                  Text(
                    "What would you like to do?",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: config.sp(18),
                    ),
                  ),
                  YMargin(16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ActionWidget(
                        title: "Schedule Appointment",
                        icon: Icons.calendar_month_outlined,
                        iconColor: const Color(0xff7C65FF),
                        onTap: () {},
                      ),
                      ActionWidget(
                        title: "Add New Task",
                        icon: Icons.task_alt_outlined,
                        iconColor: const Color(0xffFFBB00),
                        onTap: () {
                          SupabaseService.insert(table: 'tasks', data: {
                            'title': 'Finish the app',
                            'description': 'New Task Description',
                            'priority': 'low',
                            'status': 'pending',
                            'due_date': DateTime.now().toIso8601String(),
                            'created_at': DateTime.now().toIso8601String(),
                            'updated_at': DateTime.now().toIso8601String(),
                            'user_id': supabase.auth.currentUser?.id,
                          });
                        },
                      ),
                      ActionWidget(
                        title: "See Tasks",
                        icon: Icons.list_outlined,
                        iconColor: const Color(0xffFF8076),
                        onTap: () {
                          widget.onPageChange?.call(2);
                        },
                      ),
                      ActionWidget(
                        title: "Open Calendar",
                        icon: Icons.calendar_month_outlined,
                        iconColor: const Color(0xff3ABB6D),
                        onTap: () {
                          widget.onPageChange?.call(1);
                        },
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upcomingEventsList() {
    var upcomingEvents = ref.watch(calendarProvider).upcomingEvents;
    var isLoadingEvents = ref.watch(calendarProvider).isLoadingEvents;
    final textTheme = Theme.of(context).textTheme;

    if(isLoadingEvents) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if(upcomingEvents.isNotEmpty) {
      return ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final event = upcomingEvents[index];

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
          return Semantics(
            label: "Upcoming event card",
            child: UpcomingWidget(
              title: event.summary ?? "",
              description: event.description ?? "",
              time: startTimeText,
              duration: event.end?.dateTime != null && event.start?.dateTime != null ? durationText : "All day",
              color: Colors.blue,
              onTap: () {
                push(EventDetailScreen(event: event));
              },
            ),
          );
        },
        separatorBuilder: (context, index) => YMargin(5), // More space between cards
        itemCount: upcomingEvents.take(3).length,
      );
    } else {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          "You have no events coming up. Enjoy your free time!",
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
          semanticsLabel: "No upcoming events or reminders",
        ),
      );
    }
  }
}