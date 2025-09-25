import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:taski/main.dart';

class AiService {

  static final String _openAiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _openAiUrl = 'https://api.openai.com/v1/responses';
  static const String _defaultModel = 'gpt-4o-mini';

  // history: list of { 'role': 'user'|'assistant'|'system', 'text': '...' }
  static Future<Stream<String>> streamAssistantResponse({
    required String threadId,
    required String userMessage,
    Map<String, dynamic>? context,
    String? systemPrompt,
    List<Map<String, String>> history = const [],
  }) async {
    if (_openAiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY is not set');
    }

    final uri = Uri.parse(_openAiUrl);

    final request = http.Request('POST', uri);
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAiKey',
    });

    final List<Map<String, dynamic>> input = [];
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      input.add({
        'role': 'system',
        'content': [
          {'type': 'input_text', 'text': systemPrompt}
        ]
      });
    }
    for (final m in history) {
      final role = m['role'] ?? 'user';
      final text = m['text'] ?? '';
      if (text.isEmpty) continue;
      final type = role == 'assistant' ? 'output_text' : 'input_text';
      input.add({
        'role': role,
        'content': [
          {'type': type, 'text': text}
        ]
      });
    }
    input.add({
      'role': 'user',
      'content': [
        {'type': 'input_text', 'text': userMessage}
      ]
    });

    request.body = jsonEncode({
      'model': _defaultModel,
      'input': input,
      'stream': true,
    });

    

    final response = await request.send();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw StateError('OpenAI stream failed (${response.statusCode}): $body');
    }

    final controller = StreamController<String>();

    utf8.decoder.bind(response.stream).transform(const LineSplitter()).listen(
      (line) {
        if (line.trim().isEmpty) return;
        if (line.startsWith('data:')) {
          final payload = line.substring(5).trim();
          if (payload == '[DONE]') return;
          try {
            final jsonLine = jsonDecode(payload);
            final output = jsonLine['output_text'];
            if (output is String && output.isNotEmpty) {
              controller.add(output);
            } else {
              final outputArr = jsonLine['output'];
              if (outputArr is List && outputArr.isNotEmpty) {
                final content = outputArr[0]['content'];
                if (content is List && content.isNotEmpty) {
                  final text = content[0]['text'];
                  if (text is String && text.isNotEmpty) {
                    controller.add(text);
                  }
                }
              }
            }
          } catch (_) {
            // Ignore malformed lines
          }
        }
      },
      onError: (e, st) {
        controller.addError(e, st);
      },
      onDone: () {
        controller.close();
      },
      cancelOnError: false,
    );

    return controller.stream;
  }

  static Future<List<dynamic>> completeAssistantResponse({
    required String userMessage,
    String? systemPrompt,
    Map<String, dynamic>? context,
    List<Map<String, String>> history = const [],
  }) async {
    if (_openAiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY is not set');
    }

    final uri = Uri.parse(_openAiUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAiKey',
    };

    final List<Map<String, dynamic>> input = [];
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      input.add({
        'role': 'system',
        'content': [
          {'type': 'input_text', 'text': systemPrompt}
        ]
      });
    }
    for (final m in history) {
      final role = m['role'] ?? 'user';
      final text = m['text'] ?? '';
      if (text.isEmpty) continue;
      final type = role == 'assistant' ? 'output_text' : 'input_text';
      var inp = {
        'role': role,
        'content': [
          {'type': type, 'text': text}
        ]
      };
      input.add(inp);

      logger.i("OpenAI request: $inp");
    }
    input.add({
      'role': 'user',
      'content': [
        {'type': 'input_text', 'text': userMessage}
      ]
    });

    final body = jsonEncode({
      'model': _defaultModel,
      'input': input,
      'stream': false,
    });


    logger.d("OpenAI request: $body");

    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      logger.e('OpenAI completion failed (${res.statusCode})', error: res.body);
      throw StateError('OpenAI completion failed (${res.statusCode}): ${res.body}');
    }

    logger.d("OpenAI response: ${res.body}");

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    // final outputText = json['output_text'];
    // if (outputText is String && outputText.isNotEmpty) {
    //   return outputText;
    // }
    final outputArr = json['output'];
    return outputArr;   
  }
} 