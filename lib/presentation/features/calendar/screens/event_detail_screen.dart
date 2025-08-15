import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';
import 'package:taski/core/providers/calendar_provider.dart';
import 'package:taski/core/services/google_calendar_service.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final calendar.Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    // Extract event details
    final event = widget.event;
    final title = event.summary ?? "Untitled Event";
    final description = event.description ?? "";
    final startTime = event.start?.dateTime;
    final endTime = event.end?.dateTime;
    final location = event.location ?? "";
    final isAllDay = event.start?.date != null;
    final hasConference = event.conferenceData?.entryPoints?.isNotEmpty == true;
    
    // Format date and time
    String dateTimeText = "";
    if (isAllDay) {
      final date = event.start?.date;
      if (date != null) {
        dateTimeText = DateFormat('MMM dd, yyyy').format(date);
      }
    } else if (startTime != null) {
      final endTimeStr = endTime != null ? DateFormat('h:mm a').format(endTime) : "";
      dateTimeText = "${DateFormat('MMM dd, yyyy h:mm a').format(startTime)} - $endTimeStr";
    }
    
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Event Details",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: config.sp(20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Edit event
            },
            icon: Icon(
              Icons.edit,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: More options menu
            },
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),          
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: config.sw(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YMargin(16),
                  
                  // Event Title
                  Text(
                    title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: config.sp(22),
                    ),
                  ),
                  
                  YMargin(20),
                  
                  // Date & Time
                  _buildDetailRow(
                    title: "Date & Time",
                    icon: Icons.calendar_today,
                    text: dateTimeText,
                    isDark: isDark,
                  ),
                  
                  YMargin(12),
                  
                  // Location
                  if (location.isNotEmpty)
                    _buildDetailRow(
                      title: "Location",
                      icon: hasConference ? Icons.videocam : Icons.location_on,
                      text: hasConference ? "Join Conference" : location,
                      isDark: isDark,
                      isClickable: hasConference,
                      onTap: hasConference ? () {
                        final conferenceData = event.conferenceData;
                        if (conferenceData != null) {
                          final entryPoints = conferenceData.entryPoints;
                          if (entryPoints != null) {
                            final entryPoint = entryPoints.first;
                            if (entryPoint.entryPointType == "video") {
                              final url = entryPoint.uri;
                              if (url != null) {
                                log(url);
                                launchUrl(Uri.parse(url));
                              }
                            }
                          }
                        }
                      } : null,
                    ),
                  
                  if (location.isNotEmpty) YMargin(12),
                  
                  // Duration
                  if (durationText.isNotEmpty)
                    _buildDetailRow(
                      title: "Duration",
                      icon: Icons.access_time,
                      text: durationText,
                      isDark: isDark,
                    ),
                  
                  if (durationText.isNotEmpty) YMargin(12),
                  
                  // Reminder (placeholder - Google Calendar doesn't provide this directly)
                  _buildDetailRow(
                    title: "Reminder",
                    icon: Icons.notifications,
                    text: "15 minutes before",
                    isDark: isDark,
                  ),
                  
                  YMargin(12),
                  
                  // Repeat
                  _buildDetailRow(
                    title: "Repeat",
                    icon: Icons.repeat,
                    text: "Does not repeat",
                    isDark: isDark,
                  ),
                  
                  YMargin(24),
                  
                  // Notes Section
                  Text(
                    'Notes',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: config.sp(16),
                    ),
                  ),
                  
                  YMargin(12),
                  
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(config.sw(16)),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      description.isNotEmpty ? description : "No notes available",
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        fontSize: config.sp(14),
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  YMargin(32),
                  
                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isDeleting ? null : _deleteEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: config.sh(16)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isDeleting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Delete Event',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: config.sp(16),
                              ),
                            ),
                    ),
                  ),
                  
                  YMargin(32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required String title,
    required bool isDark,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: config.sh(8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.blue.shade600,
              size: 20,
            ),
            XMargin(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    fontSize: config.sp(14),
                  ),),
                  YMargin(4),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isClickable 
                          ? Colors.blue.shade600 
                          : isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontSize: config.sp(14),
                      decoration: isClickable ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
            if (isClickable)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue.shade600,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEvent() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await GoogleCalendarService.instance.deleteEvent(widget.event.id!);
      
      // Refresh events in the calendar
      await ref.read(calendarProvider.notifier).listEvents();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
} 