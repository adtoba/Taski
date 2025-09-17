import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart' show EventAttendee;
import 'package:taski/core/services/firestore_service.dart';
import 'package:taski/core/services/google_calendar_service.dart';
import 'package:taski/domain/dto/create_task_dto.dart';
import 'package:taski/domain/models/event_model.dart';
import 'package:taski/main.dart';

class ActionExecutor {

  static List<Map<String, dynamic>> parseActionList(String raw) {
    dynamic first;
    try {
      first = jsonDecode(raw);
    } catch (_) {
      // If it has code fences or extra text, try to extract the JSON bracket block
      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start >= 0 && end > start) {
        first = raw.substring(start, end + 1);
      } else {
        return [];
      }
    }

    // If first decode yields a String like "[{...}, {...}]", decode again
    if (first is String) {
      try {
        first = jsonDecode(first);
      } catch (_) {
        return [];
      }
    }

    // Normalize to a list of maps
    if (first is Map<String, dynamic>) {
      return [first];
    }
    if (first is List) {
      return first
          .whereType<Map<String, dynamic>>()
          .cast<Map<String, dynamic>>()
          .toList();
    }
    return [];
  }
  static Future<String?> tryExecute(String content) async {
    log('Trying to execute: $content');
    // Attempt to parse ACTION JSON. If not JSON or no type, return null to render as normal text.
    // Map<String, dynamic> action;
    // try {
    //   action = jsonDecode(content) as Map<String, dynamic>;
    // } catch (_) {
    //   return null;
    // }

    List<dynamic> actions = [];
    try {
      actions = parseActionList(content);
      logger.d("Actions Parsed: ${actions.toString()}");
    } catch (_) {
      return null;
    }

    for(final action in actions) {
      final type = action['type'];
      // if (type is! String) return null;

      switch (type) {
        case 'create_task':
          return _createTask(action);
        case 'create_event':
          return _createEvent(action);
        // case 'cancel_event': 
        //   return _cancelEvent(action);
        // case 'view_tasks':
        //   return _viewTasks(action);
        case 'send_email':
          return _sendEmailNow(action);
        case 'schedule_email':
          return _scheduleEmail(action);
        default:
          return null;
      }
    }
    return null;
  }

  static Future<String> _createTask(Map<String, dynamic> a) async {
    log('Creating task: $a');
    final title = (a['title'] ?? '').toString();
    if (title.isEmpty) {
      return 'I need a title to create the task.';
    }
    final due = (a['due_date'] as String?)?.trim();
    final notes = (a['description'] as String?)?.trim();
    final priority = (a['priority'] as String?)?.trim();

    var createTaskDto = CreateTaskDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      dueDate: DateTime.parse(due!),
      description: notes ?? "",
      priority: priority ?? "",
      status: 'pending',
    );

    log('Creating task: ${createTaskDto.toJson()}');

    try {
      await FirestoreService.tasks().add(createTaskDto.toJson());
      log('Task created: $createTaskDto');
    } catch (e) {
      log('Error creating task: $e');
      return 'Error creating task: $e';
    }

    return 'Task created: $title${due != null ? ' (due $due)' : ''}.';
  }

  static Future<String> _createEvent(Map<String, dynamic> a) async {
    final title = (a['title'] ?? '').toString();
    final startStr = (a['start'] ?? '').toString();
    final endStr = (a['end'] ?? '').toString();
    if (title.isEmpty || startStr.isEmpty || endStr.isEmpty) {
      return 'I need a title, start, and end time (ISO 8601) to create the event.';
    }
    DateTime? start;
    DateTime? end;
    try {
      start = DateTime.parse(startStr);
      end = DateTime.parse(endStr);
    } catch (_) {
      return 'I could not parse the provided date-time values. Please provide ISO 8601 times.';
    }

    final attendeesEmails = (a['attendees'] as List?)?.cast<dynamic>().map((e) => e.toString()).where((s) => s.contains('@')).toList() ?? <String>[];
    final attendees = attendeesEmails.map((e) => EventAttendee(email: e)).toList();
    final location = (a['location'] as String?)?.trim();
    final notes = (a['notes'] as String?)?.trim();
    final addMeet = a['add_meet_link'] == true;

    final model = EventModel(
      summary: title,
      description: notes,
      startDate: start,
      endDate: end,
      location: location,
      attendees: attendees,
      isConferenceCall: addMeet,
    );

    log(model.toJson().toString());

    await GoogleCalendarService.instance.createEvent(model);
    return 'Event created: $title (${start.toIso8601String()} - ${end.toIso8601String()})';
  }

  static Future<String> _sendEmailNow(Map<String, dynamic> a) async {
    final to = (a['to'] as List?)?.cast<dynamic>().map((e) => e.toString()).where((s) => s.contains('@')).toList() ?? <String>[];
    final subject = (a['subject'] ?? '').toString();
    final body = (a['body_markdown'] ?? '').toString();
    if (to.isEmpty || subject.isEmpty || body.isEmpty) {
      return 'I need recipients, subject, and body to send the email.';
    }
    final url = dotenv.env['MAKE_SEND_EMAIL_WEBHOOK'];
    if (url == null || url.isEmpty) {
      return 'Email send webhook is not configured.';
    }
    final res = await http.post(Uri.parse(url), headers: { 'Content-Type': 'application/json' }, body: jsonEncode({ 'to': to, 'subject': subject, 'body_markdown': body }));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return 'Email sent to ${to.join(', ')} with subject "$subject".';
    }
    return 'Failed to send email (status ${res.statusCode}).';
  }

  static Future<String> _scheduleEmail(Map<String, dynamic> a) async {
    final to = (a['to'] as List?)?.cast<dynamic>().map((e) => e.toString()).where((s) => s.contains('@')).toList() ?? <String>[];
    final subject = (a['subject'] ?? '').toString();
    final body = (a['body_markdown'] ?? '').toString();
    final sendAt = (a['send_at'] ?? '').toString();
    if (to.isEmpty || subject.isEmpty || body.isEmpty || sendAt.isEmpty) {
      return 'I need recipients, subject, body, and send_at to schedule the email.';
    }
    // Validate datetime
    try { DateTime.parse(sendAt); } catch (_) { return 'The send_at time is not a valid ISO 8601 value.'; }

    final url = dotenv.env['MAKE_SCHEDULE_EMAIL_WEBHOOK'];
    if (url == null || url.isEmpty) {
      return 'Email schedule webhook is not configured.';
    }
    final res = await http.post(Uri.parse(url), headers: { 'Content-Type': 'application/json' }, body: jsonEncode({ 'to': to, 'subject': subject, 'body_markdown': body, 'send_at': sendAt }));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return 'Email scheduled to ${to.join(', ')} for $sendAt with subject "$subject".';
    }
    return 'Failed to schedule email (status ${res.statusCode}).';
  }
} 