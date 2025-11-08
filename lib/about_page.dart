// lib/about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the same gradient as the main chat screen
    const gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        Color(0xFF0F1E3A), // Dark blue
        Color(0xFF0A142A), // Darker blue
        Color(0xFF070B1D), // Deepest blue
      ],
      stops: [0.0, 0.5, 1.0],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: gradient),
        child: Column(
          children: [
            // Custom AppBar section
            AppBar(
              title: const Text('About ApnaBot'),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Make it transparent
              elevation: 0,
            ),
            // Page Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Your Logo
                      Image.asset(
                        'assets/images/logo.png', // Make sure this path is correct
                        height: 80,
                      ),
                      const SizedBox(height: 20),
                      // App Name
                      const Text(
                        'ApnaBot',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      const Text(
                        'Your Own Smart Assistant - By Students, for Students.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(255, 255, 255, 0.8), // Fixed
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Divider(
                        height: 40,
                        color: Color.fromRGBO(255, 255, 255, 0.24), // Fixed
                        indent: 40,
                        endIndent: 40,
                      ),
                      
                      // Creators Section
                      const Text(
                        'Created By:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Developer 1
                      const Text(
                        'Ratnadip Majhi',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        '(202219tw560)',
                        style: TextStyle(fontSize: 16, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
                      ),
                      
                      const SizedBox(height: 15), // Space between developers
                      
                      // Developer 2
                      const Text(
                        'Sanchita Kumari',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        '(202219tw548)',
                        style: TextStyle(fontSize: 16, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Tech Stack
                      const Text(
                        'Tech Stack:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Flutter & Dart',
                        style: TextStyle(fontSize: 18, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
                      ),
                      const SizedBox(height: 5),
                       const Text(
                        'Groq AI (Llama 3.1)',
                        style: TextStyle(fontSize: 18, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
                      ),

                      // --- NEW SECTION ---
                      const SizedBox(height: 30),
                      const Text(
                        'Guided By:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Prof. CHANDRASHEKHAR POMU CHAVAN',
                        textAlign: TextAlign.center, // Added for potential wrapping
                        style: TextStyle(fontSize: 18, color: Color.fromRGBO(255, 255, 255, 0.7)),
                      ),
                      
                      const SizedBox(height: 20), 

                      const Text(
                        'Birla Institute of Technology And Science, Pilani (BITS Pilani)',
                        textAlign: TextAlign.center, // Added for wrapping
                        style: TextStyle(fontSize: 16, color: Color.fromRGBO(255, 255, 255, 0.7)),
                      ),
                      // --- END NEW SECTION ---

                      const SizedBox(height: 40),
                      const Text(
                        'B.Tech SDPD Project 2025', // Project
                        style: TextStyle(fontSize: 14, color: Color.fromRGBO(255, 255, 255, 0.54)), // Fixed
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}