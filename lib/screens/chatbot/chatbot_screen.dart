import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../services/gemini_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _messages.add(
      'Hello! I\'m your skin health assistant. How can I assist you today?',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addMessage(String message, bool isUser) {
    setState(() {
      _messages.add(message);
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _addMessage(text, true);
    _controller.clear();

    setState(() => _isLoading = true);

    try {
      final response = await _geminiService.sendMessage(text);
      _addMessage(response, false);
    } catch (_) {
      _addMessage(
        'The assistant could not connect. Check that the app has internet access, then try again.',
        false,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Health Assistant'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = index % 2 == 1;
                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: isUser ? 60.0 : 16.0,
                      ),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.chip,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.chip, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.chip,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.send),
            mini: true,
          ),
        ],
      ),
    );
  }
}
