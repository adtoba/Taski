import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/services/firestore_service.dart';
import 'package:taski/main.dart';

import '../../domain/models/session.dart';

class SessionProvider extends ChangeNotifier {

  List<Session> userSessions = [];

  String? currentSessionId;

  bool _isLoadingSessions = false;
  bool get isLoadingSessions => _isLoadingSessions;

  void setCurrentSessionId(String? sessionId) {
    currentSessionId = sessionId;
    notifyListeners();
  }

  Future<void> getSessions() async {
    _isLoadingSessions = true;
    userSessions.clear();
    notifyListeners();

    try {
      final sessions = await FirestoreService.sessions()
      .orderBy('createdAt', descending: true)
      .get();

      for (var session in sessions.docs) {
        userSessions.add(Session.fromJson(session.data() as Map<String, dynamic>));
      }

      logger.d("User sessions: ${userSessions.toString()}");
      notifyListeners();

    } catch (e) {
      logger.e("Error log", error: e);
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  Future<String?> createSession({String? title, DateTime? createdAt}) async {
    try {
      final session = await FirestoreService.sessions().add({
        "createdAt": createdAt,
        "title": title,
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
      });

      return session.id;

    } catch (e) {
      print(e);
    }
    return null;
  }
}

final sessionProvider = ChangeNotifierProvider<SessionProvider>((ref) {
  return SessionProvider();
});