// lib/chat_screen.dart

import 'dart:io'; // Import for File class
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard functionality
import 'package:flutter_markdown/flutter_markdown.dart';
import 'ai_service.dart'; // Import the Groq AI service
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:file_picker/file_picker.dart'; // Import File Picker
import 'about_page.dart'; // Import the About Page
import 'storage_service.dart'; // Import the Storage Service

// --- ChatMessage Data Class ---
// Defines the data structure for a single message
// Includes toJson and fromJson for saving to storage
class ChatMessage {
  final String? text; // Text content (nullable)
  final File? imageFile; // Image file (nullable)
  final String? filePath; // Generic file path (nullable)
  final bool isUser; // Tracks if the message is from the user or AI

  ChatMessage({
    this.text,
    this.imageFile,
    this.filePath,
    required this.isUser,
  }) : assert(text != null || imageFile != null || filePath != null,
           'ChatMessage must have at least text, imageFile, or filePath');

  // Converts this ChatMessage object into a Map (which can be saved as JSON)
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'imagePath': imageFile?.path,
      'filePath': filePath,
      'isUser': isUser,
    };
  }

  // Creates a new ChatMessage object from a Map (loaded from JSON)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      imageFile: json['imagePath'] != null ? File(json['imagePath']) : null,
      filePath: json['filePath'],
      isUser: json['isUser'],
    );
  }
}
// --- End of ChatMessage Class ---


// --- ChatScreen Widget ---
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// --- _ChatScreenState Class ---
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = []; 
  final AiService _ai = AiService();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _storageService.loadChatHistory();
    setState(() {
      _messages = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      
      // --- AppBar Section ---
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                 // FIX 1: Replaced print() with debugPrint()
                 debugPrint("Error loading logo: $error");
                 return const Icon(Icons.error_outline, color: Colors.red, size: 40);
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ApnaBot',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Your Own Smart Assistant - By Students, for Students.',
                  style: TextStyle(
                    fontSize: 12.0,
                    // FIX 2: Replaced .withOpacity() with .fromRGBO()
                    color: const Color.fromRGBO(255, 255, 255, 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
            tooltip: 'New Chat',
            onPressed: _clearChat,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
            tooltip: 'About App',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      
      // --- Body Section ---
      body: Stack(
        children: [
          // Layer 1: Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  Color(0xFF0F1E3A),
                  Color(0xFF0A142A),
                  Color(0xFF070B1D),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Layer 2: Particle Effect
          Positioned.fill(
            child: CustomPaint(
              painter: ParticlePainter(),
            ),
          ),
          
          // Layer 3: Chat Content
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 20, bottom: 100),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),
              
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
                ),
                
              _buildInputArea(),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  // --- Message Bubble Widget (with Copy on Long Press) ---
  Widget _buildMessageBubble(ChatMessage msg) {
    final Alignment alignment = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final List<Color> gradientColors = msg.isUser
        ? [const Color(0xFF6A82FB), const Color(0xFFFC5C7D)]
        : [const Color(0xFF2E3A59), const Color(0xFF1E2841)];

    final double borderRadius = 20.0;

    Widget buildContent() {
      List<Widget> contentWidgets = [];

      // Display Image
      if (msg.imageFile != null) {
        contentWidgets.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius - 5),
            child: Image.file(
              msg.imageFile!,
              height: 150,
              fit: BoxFit.cover,
               errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.error, color: Colors.white)),
            ),
          )
        );
        if (msg.text != null || msg.filePath != null) {
          contentWidgets.add(const SizedBox(height: 8));
        }
      }

      // Display File Path
      if (msg.filePath != null && msg.imageFile == null) {
        contentWidgets.add(
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               // FIX 2: Replaced .withOpacity()
               color: const Color.fromRGBO(0, 0, 0, 0.2),
               borderRadius: BorderRadius.circular(8),
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const Icon(Icons.insert_drive_file_outlined, color: Color.fromRGBO(255, 255, 255, 0.7), size: 20), // Fixed
                 const SizedBox(width: 8),
                 Flexible(
                   child: Text(
                     'File: ${msg.filePath!.split('/').last}',
                     style: const TextStyle(color: Colors.white, fontSize: 14),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
               ],
             ),
           )
        );
        if (msg.text != null) {
           contentWidgets.add(const SizedBox(height: 8));
        }
      }

      // Display Text
      if (msg.text != null && msg.text!.trim().isNotEmpty) {
        contentWidgets.add(
          MarkdownBody(
            data: msg.text!,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Colors.white, fontSize: 16),
              strong: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      if (contentWidgets.isEmpty) {
         return const Text('[Attachment]', style: TextStyle(color: Colors.grey));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contentWidgets,
      );
    } // End of buildContent()

    // Main bubble structure
    return Align(
      alignment: alignment,
      child: InkWell(
        onLongPress: () {
          if (msg.text != null && msg.text!.trim().isNotEmpty) {
            Clipboard.setData(ClipboardData(text: msg.text!));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message copied to clipboard!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(msg.isUser ? borderRadius : 5),
          bottomRight: Radius.circular(msg.isUser ? 5 : borderRadius),
        ),
        
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
              bottomLeft: Radius.circular(msg.isUser ? borderRadius : 5),
              bottomRight: Radius.circular(msg.isUser ? 5 : borderRadius),
            ),
            boxShadow: [
              BoxShadow(
                // FIX 2: Replaced .withOpacity()
                color: const Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: buildContent(),
        ),
      ),
    );
  }
  // --- End of Message Bubble ---


  // --- Input Area Widget ---
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        // FIX 2: Replaced .withOpacity()
        color: const Color.fromRGBO(255, 255, 255, 0.08),
        borderRadius: BorderRadius.circular(30.0),
        // FIX 2: Replaced .withOpacity()
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.15)),
        boxShadow: [
          BoxShadow(
            // FIX 2: Replaced .withOpacity()
            color: const Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // File Picker Button
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
            tooltip: 'Attach File',
            onPressed: _pickFile,
          ),
          // Gallery Picker Button
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
             tooltip: 'Pick Image from Gallery',
            onPressed: _pickImageFromGallery,
          ),
          // Camera Button
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Color.fromRGBO(255, 255, 255, 0.7)), // Fixed
             tooltip: 'Take Photo',
            onPressed: _takePhoto,
          ),
          // Text Input Field
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (value) => _sendMessage(),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type message...',
                // FIX 2: Replaced Colors.white54
                hintStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.54)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
              ),
            ),
          ),
          // Send Button
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _isLoading ? null : _sendMessage,
            splashColor: const Color.fromRGBO(33, 150, 243, 0.3),
          ),
        ],
      ),
    );
  }
  // --- End of Input Area ---

  // --- Send Message Logic ---
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isLoading) return;

    final text = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    try {
      final response = await _ai.getResponse(text);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
      });
      
      await _storageService.saveChatHistory(_messages);
      
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Error: ${e.toString()}', isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // --- Clear Chat Function ---
  void _clearChat() {
    _ai.clearChatHistory(); 
    _storageService.clearChatHistory();
    setState(() {
      _messages.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat cleared!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // --- Picker Functions ---

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _addAttachmentToChat(imageFile: File(pickedFile.path));
      }
    } catch (e) {
       // FIX 1: Replaced print()
       debugPrint("Error picking image from gallery: $e");
       
       // FIX 3: Added 'mounted' check
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error picking image: ${e.toString()}'))
       );
    }
  }

  Future<void> _takePhoto() async {
     try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _addAttachmentToChat(imageFile: File(pickedFile.path));
      }
     } catch (e) {
       // FIX 1: Replaced print()
       debugPrint("Error taking photo: $e");
       
       // FIX 3: Added 'mounted' check
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error taking photo: ${e.toString()}'))
       );
     }
  }

  Future<void> _pickFile() async {
     try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        _addAttachmentToChat(filePath: result.files.single.path!);
      }
     } catch (e) {
       // FIX 1: Replaced print()
       debugPrint("Error picking file: $e");
       
       // FIX 3: Added 'mounted' check
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error picking file: ${e.toString()}'))
       );
     }
  }

  // Helper function to add attachments
  void _addAttachmentToChat({File? imageFile, String? filePath}) {
     setState(() {
       _messages.add(ChatMessage(
         imageFile: imageFile,
         filePath: filePath,
         isUser: true,
         text: imageFile != null
             ? '(Image: ${imageFile.path.split('/').last})'
             : (filePath != null ? '(File: ${filePath.split('/').last})' : null)
       ));
     });
     
     _storageService.saveChatHistory(_messages);
  }
  // --- End of Picker Functions ---

} // --- End of _ChatScreenState class ---


// --- Particle Painter Class ---
class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // FIX 2: Replaced .withOpacity()
    final Paint paint = Paint()..color = const Color.fromRGBO(255, 255, 255, 0.08);
    
    for (int i = 0; i < 50; i++) {
      final double x = (i * 20 + (i % 5) * 50 + DateTime.now().millisecond / 10).toDouble() % size.width;
      final double y = (i * 30 + (i % 3) * 70 + DateTime.now().millisecond / 15).toDouble() % size.height;
      
      canvas.drawCircle(Offset(x, y), 1.0 + (i%2)*0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}