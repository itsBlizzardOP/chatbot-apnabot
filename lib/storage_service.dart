// lib/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart'; // Import your ChatMessage class
import 'package:flutter/foundation.dart'; // <-- ADD THIS IMPORT

class StorageService {
  // The key we'll use to save the chat history in shared_preferences
  static String get _historyKey => 'chat_history';

  // --- Saves the entire chat history ---
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    try {
      // 1. Get the shared_preferences instance
      final prefs = await SharedPreferences.getInstance();
      
      // 2. Convert List<ChatMessage> to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> messagesJson = 
          messages.map((msg) => msg.toJson()).toList();
          
      // 3. Convert List<Map> to a List<String>
      final List<String> messagesStringList = 
          messagesJson.map((json) => jsonEncode(json)).toList();
          
      // 4. Save the list
      await prefs.setStringList(_historyKey, messagesStringList);
    } catch (e) {
      // --- FIX 1 ---
      debugPrint("Error saving chat history: $e");
    }
  }

  // --- Loads the entire chat history ---
  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Load the List<String>
      final List<String>? messagesStringList = 
          prefs.getStringList(_historyKey);
          
      if (messagesStringList == null) {
        return []; // No history found, return empty list
      }
      
      // 2. Convert List<String> back to List<ChatMessage>
      final List<ChatMessage> messages = messagesStringList.map((jsonString) {
        // 3. Decode the string back to a Map
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        // 4. Convert the Map back to a ChatMessage
        return ChatMessage.fromJson(jsonMap);
      }).toList();
      
      return messages;
    } catch (e) {
      // --- FIX 2 ---
      debugPrint("Error loading chat history: $e");
      return []; // On error, return empty list
    }
  }

  // --- Clears the chat history ---
  Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey); // Remove the key
  }
}