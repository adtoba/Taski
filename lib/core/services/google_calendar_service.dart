import 'dart:developer';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:taski/domain/models/event_model.dart';
import 'package:taski/main.dart';


class GoogleCalendarService {

  static final GoogleCalendarService _googleCalendarService = GoogleCalendarService._();

  GoogleCalendarService._();

  static GoogleCalendarService get instance => _googleCalendarService;

  List<String> scopes = [
    'https://www.googleapis.com/auth/calendar',
    'openid',
    'email',
    'profile',
  ];

  String calendarId = "primary";
  
  Future<auth.AuthClient> getAuthClient() async {
    final googleSignIn = GoogleSignIn.instance;
    var authorization = await googleSignIn.authorizationClient.authorizationForScopes(
      <String>[CalendarApi.calendarScope]
    );
    return authorization!.authClient(scopes: scopes);
  }

  Future<Events> listEvents() async {
    var client = await getAuthClient();
    final calendarApi = CalendarApi(client);

    var events = await calendarApi.events.list(calendarId);
    return events;
  }

  Future<Event> getEvent(String eventId) async {
    var client = await getAuthClient();
    final calendarApi = CalendarApi(client);

    var event = await calendarApi.events.get(calendarId, eventId);
    return event;
  }

  Future<void> createEvent(EventModel eventModel) async {
    var client = await getAuthClient();
    final userEmail = supabase.auth.currentUser?.email ?? "";
    final userName = supabase.auth.currentUser?.userMetadata?["name"] ?? "";

    final calendarApi = CalendarApi(client);

    final timezone = await FlutterTimezone.getLocalTimezone();

    final event = Event()
      ..summary = eventModel.summary
      ..description = eventModel.description
      ..location = eventModel.location
      ..creator = EventCreator(displayName: userName, email: userEmail)
      ..guestsCanSeeOtherGuests = true
      ..start = EventDateTime(dateTime: eventModel.startDate, timeZone: timezone)
      ..end = EventDateTime(dateTime: eventModel.endDate, timeZone: timezone)
      ..attendees = eventModel.attendees;

    if(eventModel.isConferenceCall!) {
      event.conferenceData = ConferenceData(
        createRequest: CreateConferenceRequest(
          requestId: "unique-request-id-${DateTime.now().millisecondsSinceEpoch}",
          conferenceSolutionKey: ConferenceSolutionKey(type: "hangoutsMeet"),
        ),
      );
    }
    await calendarApi.events.insert(
      event, calendarId, conferenceDataVersion: eventModel.isConferenceCall! ? 1 : null
    );
  }

  Future<void> deleteEvent(String eventId) async {
    var client = await getAuthClient();
    final calendarApi = CalendarApi(client);

    await calendarApi.events.delete(calendarId, eventId, sendNotifications: true);
  }

  Future<void> updateEvent(String eventId, EventModel eventModel) async {
    var client = await getAuthClient();
    final userEmail = supabase.auth.currentUser?.email ?? "";
    final userName = supabase.auth.currentUser?.userMetadata?["name"] ?? "";

    final calendarApi = CalendarApi(client);

    final timezone = await FlutterTimezone.getLocalTimezone();

    final event = Event()
      ..summary = eventModel.summary
      ..description = eventModel.description
      ..creator = EventCreator(displayName: userName, email: userEmail)
      ..location = eventModel.location
      ..start = EventDateTime(dateTime: eventModel.startDate, timeZone: timezone)
      ..end = EventDateTime(dateTime: eventModel.endDate, timeZone: timezone)
      ..attendees = eventModel.attendees;

    if(eventModel.isConferenceCall!) {
      event.conferenceData = ConferenceData(
        createRequest: CreateConferenceRequest(
          requestId: "unique-request-id-${DateTime.now().millisecondsSinceEpoch}",
          conferenceSolutionKey: ConferenceSolutionKey(type: "hangoutsMeet"),
        ),
      );
    }

    await calendarApi.events.update(event, calendarId, eventId, conferenceDataVersion: eventModel.isConferenceCall! ? 1 : null);
  }
  
}