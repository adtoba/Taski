import 'package:googleapis/calendar/v3.dart';

class EventModel {
  final String? summary;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final bool? isConferenceCall;
  final List<EventAttendee>? attendees;

  EventModel({
    this.summary, 
    this.description, 
    this.startDate, 
    this.endDate, 
    this.location, 
    this.attendees, 
    this.isConferenceCall = false
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      summary: json['summary'],
      description: json['description'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      attendees: json['attendees']?.map((e) => EventAttendee.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'attendees': attendees,
      'isConferenceCall': isConferenceCall,
      'location': location,
    };
  }
}