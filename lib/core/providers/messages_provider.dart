import 'dart:developer';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/services/firestore_service.dart';
import 'package:taski/domain/dto/create_message_dto.dart';
import 'package:taski/domain/models/message.dart';
import 'package:taski/core/services/ai_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taski/core/services/ai_prompt.dart';
import 'package:taski/core/services/action_executor.dart';


class MessagesProvider extends ChangeNotifier {

  List<ChatMessage> userMessages = [];

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;


  Future<void> getMessages({String? sessionId}) async {

    try {
      final messages = await FirestoreService.messages()
        .where("sessionId", isEqualTo: sessionId)
        .orderBy("createdAt", descending: false)
        .get();

      userMessages.clear();
      notifyListeners();
      for (var message in messages.docs) {
        userMessages.add(ChatMessage.fromJson(message.data() as Map<String, dynamic>));
      }
      log(userMessages.toString());
       notifyListeners();

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        notifyListeners();
      }
     

    } catch (e) {
      print(e);
    }
  }

  bool isLoading = false;
  Future<void> sendMessage({String? sessionId, String? content, bool? isUser, String? type}) async {
    try {
      isLoading = true;
      notifyListeners();
      var message = CreateMessageDto(
        sessionId: sessionId,
        content: content,
        isUser: isUser,
        type: type,
        createdAt: DateTime.now().toIso8601String(),
      );

      await FirestoreService.messages().add(message.toJson());
      await getMessages(sessionId: sessionId);
      notifyListeners();

    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, String>>> _loadRecentHistory(String sessionId, {int limit = 12}) async {
    final query = await FirestoreService.messages()
      .where("sessionId", isEqualTo: sessionId)
      .orderBy("createdAt", descending: true)
      .limit(limit)
      .get();

    final docs = query.docs.map((d) => ChatMessage.fromJson(d.data() as Map<String, dynamic>)).toList().reversed;
    return docs.map((m) => {
      'role': (m.isUser ?? false) ? 'user' : 'assistant',
      'text': m.content ?? '',
    }).where((m) => m['text']!.isNotEmpty).toList();
  }

  Future<void> sendUserMessageAndStreamAssistant({
    required String sessionId,
    required String content,
    String type = 'text',
    String? threadId,
    Map<String, dynamic>? context,
  }) async {
    await sendMessage(sessionId: sessionId, content: content, isUser: true, type: type);

    final assistantDoc = await FirestoreService.messages().add({
      'sessionId': sessionId,
      'content': '',
      'isUser': false,
      'type': 'text',
      'createdAt': DateTime.now().toIso8601String(),
    });

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final tz = await FlutterTimezone.getLocalTimezone();
    final systemPrompt = AiPrompt.build(userId: userId, timezone: tz);
    final history = await _loadRecentHistory(sessionId);

    try {
      final stream = await AiService.streamAssistantResponse(
        threadId: threadId ?? sessionId,
        userMessage: content,
        context: context,
        systemPrompt: systemPrompt,
        history: history,
      );

      String buffer = '';
      final completer = Completer<void>();

      stream.listen((delta) async {
        buffer += delta;
        await assistantDoc.update({ 'content': buffer });
      }, onError: (e) async {
        await assistantDoc.update({ 'content': buffer.isEmpty ? 'Sorry, something went wrong.' : buffer });
        completer.complete();
      }, onDone: () async {
        await assistantDoc.update({ 'content': buffer });
        completer.complete();
      });

      await completer.future;

      final confirmation = await ActionExecutor.tryExecute(buffer);
      if (confirmation != null) {
        await assistantDoc.update({ 'content': confirmation });
      }

      notifyListeners();
    } catch (e) {
      await assistantDoc.update({ 'content': 'Sorry, something went wrong.' });
      notifyListeners();
    }
  }

  bool isCompleteLoading = false;

  Future<void> sendUserMessageAndCompleteAssistant({
    required String sessionId,
    required String content,
    String type = 'text',
    Map<String, dynamic>? context,
  }) async {
    await sendMessage(sessionId: sessionId, content: content, isUser: true, type: type);

    isCompleteLoading = true;
    notifyListeners();

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final tz = await FlutterTimezone.getLocalTimezone();
    final systemPrompt = AiPrompt.build(userId: userId, timezone: tz);
    final history = await _loadRecentHistory(sessionId);

    List<dynamic> result = [];
    try {
      result = await AiService.completeAssistantResponse(
        userMessage: content,
        systemPrompt: systemPrompt,
        context: context,
        history: history,
      );

      log("Result: $result");
    } catch (e) {
      result = [];
    }

    if(result.isNotEmpty) {
      for(var item in result) {
        log(item['content'][0]['text']);
        await ActionExecutor.tryExecute(item['content'][0]['text']);
      }
      final contentToSave = result[0]['content'][0]['text'];
      log(contentToSave);

      await FirestoreService.messages().add({
        'sessionId': sessionId,
        'content': contentToSave,
        'isUser': false,
        'type': 'text',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    await getMessages(sessionId: sessionId);
    isCompleteLoading = false;
    notifyListeners();
  }
}

final messagesProvider = ChangeNotifierProvider<MessagesProvider>((ref) {
  return MessagesProvider();
});