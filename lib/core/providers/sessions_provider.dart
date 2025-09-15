import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/services/firestore_service.dart';

import '../../domain/models/session.dart';

class SessionProvider extends ChangeNotifier {

  List<Session> userSessions = [];

  String? currentSessionId;

  void setCurrentSessionId(String? sessionId) {
    currentSessionId = sessionId;
    notifyListeners();
  }

  Future<void> getSessions() async {
    userSessions.clear();
    notifyListeners();

    try {
      final sessions = await FirestoreService.sessions().get();

      for (var session in sessions.docs) {
        userSessions.add(Session.fromJson(session.data() as Map<String, dynamic>));
      }

      log(userSessions.toString());
      notifyListeners();

    } catch (e) {
      print(e);
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