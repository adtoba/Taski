import 'dart:convert';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:taski/main.dart';

class OpenAIService {
  // Returns a normalized list of actions parsed from the assistant output.
  // If the assistant asks a clarifying question (plain text), this returns an empty list.
  static Future<String> chatAssistantResponse({
    required String userMessage,
    String? systemPrompt,
    Map<String, dynamic>? context,
    List<Map<String, String>> history = const [],
  }) async {

    logger.i('OpenAI system prompt: $systemPrompt');

    // Build system message
    final system = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          systemPrompt ?? '',
        ),
      ],
    );

    // Build history (user/assistant turns in order)
    final List<OpenAIChatCompletionChoiceMessageModel> messages = [];
    for (final h in history) {
      final roleStr = h['role'] ?? 'user';
      final role = roleStr == 'assistant'
          ? OpenAIChatMessageRole.assistant
          : (roleStr == 'system' ? OpenAIChatMessageRole.system : OpenAIChatMessageRole.user);
      final text = h['text'] ?? '';
      if (text.isEmpty) continue;
      messages.add(OpenAIChatCompletionChoiceMessageModel(
        role: role,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(text)],
      ));
    }

    // Latest user message last
    final user = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage)],
    );

    final requestMessages = [system, ...messages, user];

    final chat = await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini',
      messages: requestMessages,
      temperature: 0.7,
      maxTokens: 1000,
      topP: 1,
    );

    // Join all text parts from the first choice
    final parts = chat.choices.first.message.content ?? [];
    final fullText = parts.map((p) => p.text ?? '').join('').trim();
    logger.i('OpenAI chat output: $fullText');

    return fullText;

    // Try to parse actions (JSON array or object). If parsing fails, return empty list.
    // return _tryParseActions(fullText);
  }

  static Future<String> voiceTranscription(String audioPath) async {
    final transcription = await OpenAI.instance.audio.createTranscription(
      file: await getFileFromPath(audioPath), 
      model: 'whisper-1'
    );

    logger.d("Transcription: ${transcription.text}");
    return transcription.text;
  }

  static Future<File> getFileFromPath(String path) async {
    return File(path);
  }

  static List<dynamic> _tryParseActions(String raw) {
    if (raw.isEmpty) return [];

    dynamic decoded;

    // First attempt: raw is already a JSON array/object
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      // Try to extract a JSON array
      final s = raw.indexOf('[');
      final e = raw.lastIndexOf(']');
      if (s >= 0 && e > s) {
        final slice = raw.substring(s, e + 1);
        try { decoded = jsonDecode(slice); } catch (_) {}
      }
      // If array failed, try single object
      if (decoded == null) {
        final s2 = raw.indexOf('{');
        final e2 = raw.lastIndexOf('}');
        if (s2 >= 0 && e2 > s2) {
          final slice = raw.substring(s2, e2 + 1);
          try { decoded = jsonDecode(slice); } catch (_) {}
        }
      }
    }

    if (decoded == null) return [];
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) return [decoded];
    return [];
  }
}