import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../../../models/chat_message.dart';
import '../../../services/ai_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Hi! I'm your AI Study Assistant.\n\nI can help you with:\n- Study techniques\n- Assignment planning\n- GPA improvement\n- Time management\n- Exam stress tips\n\nAsk me anything!",
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollDown();

    final response = await AiService.sendMessage(text);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response, isUser: false, time: DateTime.now()));
    });
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startListening() async {
    final available = await _speech.initialize();
    if (!available) return;
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        _ctrl.text = result.recognizedWords;
        if (result.finalResult && _ctrl.text.trim().isNotEmpty) {
          _sendMessage(_ctrl.text);
          setState(() => _isListening = false);
        }
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_ctrl.text.trim().isNotEmpty) {
      _sendMessage(_ctrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Study Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                Text('Powered by Gemini', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return _typingIndicator(isDark);
                }
                return _messageBubble(_messages[i], isDark);
              },
            ),
          ),
          _buildQuickActions(),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _quickChip('Study Tips', () => _sendMessage('Give me study tips')),
          const SizedBox(width: 8),
          _quickChip('Study Plan', () async {
            setState(() => _isTyping = true);
            final response = await AiService.generateStudyPlan();
            if (!mounted) return;
            setState(() {
              _isTyping = false;
              _messages.add(ChatMessage(text: response, isUser: false, time: DateTime.now()));
            });
            _scrollDown();
          }),
          const SizedBox(width: 8),
          _quickChip('My Progress', () async {
            setState(() => _isTyping = true);
            final response = await AiService.analyzeProgress();
            if (!mounted) return;
            setState(() {
              _isTyping = false;
              _messages.add(ChatMessage(text: response, isUser: false, time: DateTime.now()));
            });
            _scrollDown();
          }),
          const SizedBox(width: 8),
          _quickChip('Help', () => _sendMessage('I need help with studying')),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.2),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            onSubmitted: _sendMessage,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ask Gemini anything...',
              hintStyle: const TextStyle(color: AppColors.textHint),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            _isListening ? Icons.mic_off : Icons.mic,
            color: _isListening ? Colors.red : AppColors.textSecondary,
          ),
          onPressed: _isListening ? _stopListening : _startListening,
        ),
        GestureDetector(
          onTap: () => _sendMessage(_ctrl.text),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
          ),
        ),
      ]),
    );
  }

  Widget _messageBubble(ChatMessage msg, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: msg.isUser
              ? AppColors.primaryGradient
              : null,
          color: msg.isUser ? null : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Thinking', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          SizedBox(
            width: 40, height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) => _dot(i * 200)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
