// lib/main.dart
import 'package:flutter/material.dart';
import 'chat_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApnaBot',
      theme: ThemeData(
        brightness: Brightness.dark, // Overall dark theme
        primarySwatch: Colors.blue, // A primary color, though we'll use gradients
        scaffoldBackgroundColor: Colors.black, // Dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Make app bar transparent
          elevation: 0, // No shadow
          foregroundColor: Colors.white, // White text for title
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
    );
  }
}