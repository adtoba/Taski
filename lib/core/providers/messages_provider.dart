import 'dart:developer';
import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/providers/sessions_provider.dart';
import 'package:taski/core/services/firebase_storage_service.dart';
import 'package:taski/core/services/firestore_service.dart';
import 'package:taski/core/services/openai_service.dart';
import 'package:taski/domain/dto/create_message_dto.dart';
import 'package:taski/domain/models/message.dart';
import 'package:taski/core/services/ai_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taski/core/services/ai_prompt.dart';
import 'package:taski/core/services/action_executor.dart';
import 'package:taski/main.dart';

MessagesProvider get messageProvider {
  final ctx = navigatorKey.currentContext!;
  final container = ProviderScope.containerOf(ctx, listen: false);
  return container.read(messagesProvider);
}

class MessagesProvider extends ChangeNotifier {

  final Ref? ref;

  MessagesProvider({this.ref});

  List<ChatMessage> userMessages = [];

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  bool isFetchingMessages = false;

  Future<void> getMessages({String? sessionId}) async {
    userMessages.clear();
    isFetchingMessages = true;
    notifyListeners();

    try {
      final messages = await FirestoreService.messages()
        .where("sessionId", isEqualTo: sessionId)
        .orderBy("createdAt", descending: false)
        .get();

      for (var message in messages.docs) {
        userMessages.add(ChatMessage.fromJson(message.data() as Map<String, dynamic>));
      }

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        notifyListeners();
      }

    } catch (e) {
      logger.e("Error fetching messages:", error: e);
    } finally {
      isFetchingMessages = false;
      notifyListeners();
    }
  }

  bool isLoading = false;
  Future<void> sendMessage({
    String? sessionId, 
    String? content, 
    bool? isUser, 
    String? type, 
    String? path,
    String? transcription,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      var message = CreateMessageDto(
        sessionId: sessionId,
        content: content,
        isUser: isUser,
        type: type,
        path: path,
        transcription: transcription,
        createdAt: DateTime.now().toIso8601String(),
      );

      logger.d("Message: ${message.toJson()}");

      await FirestoreService.messages().add(message.toJson());
      userMessages.add(ChatMessage.fromJson(message.toJson()));
      // await getMessages(sessionId: sessionId);
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

  // For audio messages
  bool isCompleteLoading = false;
  Future<void> sendUserMessageAndUploadAudio({
    String? sessionId,
    required String filePath,
    String type = 'audio',
    Map<String, dynamic>? context,
  }) async {

    isCompleteLoading = true;
    notifyListeners();

    Map<String, dynamic> res = await FirebaseStorageService.uploadFile(filePath, filePath.split('/').last);
    String? url = res['url'];

    if(url == null) {
      return;
    }

    final transcription = await OpenAIService.voiceTranscription(filePath);
    logger.d("Transcription: $transcription");

    await sendMessage(
      sessionId: sessionId ?? ref?.read(sessionProvider).currentSessionId ?? '', 
      content: url, 
      isUser: true, 
      path: filePath,
      transcription: transcription,
      type: type
    );

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final tz = await FlutterTimezone.getLocalTimezone();
    final systemPrompt = AiPrompt.build(userId: userId, timezone: tz);
    final history = await _loadRecentHistory(sessionId ?? ref?.read(sessionProvider).currentSessionId ?? '');

    String result;
    try {
      result = await OpenAIService.chatAssistantResponse(
        userMessage: transcription,
        systemPrompt: systemPrompt,
        context: context,
        history: history,
      );

      log("Result: $result");
    } catch (e) {
      result = '';
    }

    await ActionExecutor.tryExecute(result);

    await sendMessage(
      sessionId: sessionId ?? ref?.read(sessionProvider).currentSessionId ?? '', 
      content: result, 
      isUser: false, 
      type: 'text',
      transcription: transcription,
    );
    
    isCompleteLoading = false;
    notifyListeners();
  }

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

    String result;
    try {
      result = await OpenAIService.chatAssistantResponse(
        userMessage: content,
        systemPrompt: systemPrompt,
        context: context,
        history: history,
      );

      log("Result: $result");
    } catch (e) {
      result = '';
      return;
    }

    await ActionExecutor.tryExecute(result);
    await sendMessage(
      sessionId: sessionId,
      content: result,
      isUser: false,
      type: 'text',
      path: null,
    );

    isCompleteLoading = false;
    notifyListeners();
  }
}

final messagesProvider = ChangeNotifierProvider<MessagesProvider>((ref) {
  return MessagesProvider(ref: ref);
});