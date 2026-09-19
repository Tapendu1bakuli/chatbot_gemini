import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'chat_message.dart';
import 'config.dart';

// Talks to the Gemini API over plain HTTP.
// No special SDK needed: we send JSON and read JSON back.
class GeminiService {
  static final Uri _url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent',
  );

  // Sends the whole conversation to Gemini and returns the AI's reply.
  // (The API remembers nothing, so we send the full history every time.)
  Future<String> sendMessage(List<ChatMessage> messages) async {
    if (geminiApiKey.startsWith('PASTE_')) {
      throw Exception('Add your Gemini API key in lib/config.dart first.');
    }

    // Convert our messages into the format Gemini expects.
    final contents = <Map<String, dynamic>>[];
    for (final message in messages) {
      if (message.isError) continue; // never send error bubbles to the AI
      contents.add({
        'role': message.isUser ? 'user' : 'model',
        'parts': [
          {'text': message.text},
        ],
      });
    }

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': contents,
    });

    http.Response response;
    try {
      response = await http
          .post(
            _url,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': geminiApiKey,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    } catch (_) {
      throw Exception('Could not reach Gemini. Check your internet connection.');
    }

    if (response.statusCode != 200) {
      throw Exception(_readError(response));
    }

    return _readReply(response);
  }

  // Pulls the reply text out of Gemini's JSON answer.
  String _readReply(http.Response response) {
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception(
        'Gemini did not return an answer (the message may have been blocked). '
        'Try rephrasing it.',
      );
    }

    final first = candidates.first as Map<String, dynamic>;
    final content = first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null) {
      throw Exception('Gemini returned an empty answer. Please try again.');
    }

    final text = parts
        .whereType<Map<String, dynamic>>()
        .where((part) => part['thought'] != true)
        .map((part) => part['text'] as String? ?? '')
        .join()
        .trim();

    if (text.isEmpty) {
      throw Exception('Gemini returned an empty answer. Please try again.');
    }
    return text;
  }

  // Turns an HTTP error into a message a beginner can understand.
  String _readError(http.Response response) {
    String? apiMessage;
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      apiMessage = data['error']['message'] as String?;
    } catch (_) {
      // The body was not the JSON we expected. Use the fallbacks below.
    }

    if (response.statusCode == 404) {
      return 'Model "$geminiModel" was not found. '
          'Change geminiModel in lib/config.dart.';
    }
    if (response.statusCode == 429) {
      return 'Too many requests or the free quota is used up. '
          'Wait a minute and try again.';
    }
    return apiMessage ?? 'Request failed (HTTP ${response.statusCode}).';
  }
}
