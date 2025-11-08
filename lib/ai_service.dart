// lib/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // <-- ADD THIS IMPORT

class AiService {
  final String _apiKey = "Groq_API_Key";
  final String _url = "https://api.groq.com/openai/v1/chat/completions";

  // Store the system prompt
  final Map<String, String> _systemPrompt = {
    "role": "system",
    "content": "You are a helpful, general-purpose assistant."
  };

  // Make the messages list non-final
  List<Map<String, String>> _messages = [];

  AiService() {
    // Call the new clear function to initialize
    clearChatHistory();
  }

  // This function clears the AI's memory and re-adds the system prompt.
  void clearChatHistory() {
    _messages = [];
    _messages.add(_systemPrompt);
  }

  Future<String> getResponse(String userQuestion) async {
    try {
      _messages.add({
        "role": "user",
        "content": userQuestion,
      });

      final request = http.Request("POST", Uri.parse(_url));
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Content-Type'] = 'application/json';

      final requestBody = {
        "messages": _messages,
        "model": "llama-3.1-8b-instant",
        "temperature": 0.7,
      };

      request.body = jsonEncode(requestBody);
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final aiResponse = jsonResponse['choices'][0]['message']['content'];

        _messages.add({
          "role": "assistant",
          "content": aiResponse,
        });

        return aiResponse;
      } else {
        // --- FIX 1 ---
        debugPrint("Error: ${response.statusCode}");
        // --- FIX 2 ---
        debugPrint("Response Body: $responseBody");
        return "An error occurred (Code: ${response.statusCode}).";
      }
    } catch (e) {
      // --- FIX 3 ---
      debugPrint("Error in getResponse: $e");
      return "An error occurred. Please try again.";
    }
  }
}
