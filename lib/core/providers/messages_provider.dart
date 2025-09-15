import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/services/firestore_service.dart';
import 'package:taski/domain/dto/create_message_dto.dart';
import 'package:taski/domain/models/message.dart';


class MessagesProvider extends ChangeNotifier {

  List<ChatMessage> userMessages = [];

  Future<void> getMessages({String? sessionId}) async {
    userMessages.clear();
    notifyListeners();

    try {
      final messages = await FirestoreService.messages().where("sessionId", isEqualTo: sessionId).get();

      for (var message in messages.docs) {
        userMessages.add(ChatMessage.fromJson(message.data() as Map<String, dynamic>));
      }

      log(userMessages.toString());
      notifyListeners();

    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage({String? sessionId, String? content, bool? isUser, String? type}) async {
    try {
      var message = CreateMessageDto(
        sessionId: sessionId,
        content: content,
        isUser: isUser,
        type: type,
        createdAt: DateTime.now().toIso8601String(),
      );

      await FirestoreService.messages().add(message.toJson());

      notifyListeners();

    } catch (e) {
      print(e);
    }
  }
}

final messagesProvider = ChangeNotifierProvider<MessagesProvider>((ref) {
  return MessagesProvider();
});