import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

/// Message model for chat UI
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, required this.time});
}

/// AI Study Assistant screen - answers student questions using rule-based AI
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});
  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll   = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  /// Quick suggestion chips shown to user
  final List<String> _suggestions = [
    'How to study effectively?',
    'Tips to improve attendance',
    'How to manage assignments?',
    'Best study schedule tips',
    'How to calculate GPA?',
    'Pomodoro technique tips',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message from AI
    _messages.add(ChatMessage(
      text: "Hi! 👋 I'm your Smart Study Assistant.\n\nI can help you with:\n• Study tips & techniques\n• Time management advice\n• Assignment planning\n• Attendance strategies\n• GPA improvement tips\n\nWhat would you like to know?",
      isUser: false,
      time: DateTime.now(),
    ));
  }

  /// Generate AI response based on keywords in user message
  String _generateResponse(String input) {
    final msg = input.toLowerCase();

    if (msg.contains('study') && msg.contains('effective')) {
      return "📚 Here are effective study techniques:\n\n1️⃣ Use the Pomodoro technique - study 25 mins, break 5 mins\n2️⃣ Active recall - test yourself instead of re-reading\n3️⃣ Spaced repetition - review after 1 day, 3 days, 1 week\n4️⃣ Teach what you learn to someone else\n5️⃣ Study in a quiet, distraction-free environment\n\n💡 Tip: Use the Pomodoro Timer in this app!";
    }
    else if (msg.contains('attendance')) {
      return "✅ Tips to improve attendance:\n\n1️⃣ Set morning alarms for every class\n2️⃣ Track attendance in this app daily\n3️⃣ Keep attendance above 75% always\n4️⃣ If you miss a class, get notes from classmates\n5️⃣ Inform the teacher in advance if you'll miss class\n\n⚠️ Remember: Below 75% can cause exam issues!";
    }
    else if (msg.contains('assignment') || msg.contains('task')) {
      return "📋 Assignment management tips:\n\n1️⃣ Add all assignments in the Tasks screen immediately\n2️⃣ Set priority - High for urgent tasks\n3️⃣ Break big assignments into smaller steps\n4️⃣ Start at least 3 days before the deadline\n5️⃣ Review your tasks list every morning\n\n💡 Use the Tasks screen to never miss a deadline!";
    }
    else if (msg.contains('gpa') || msg.contains('grade')) {
      return "🎓 GPA improvement tips:\n\n1️⃣ Aim for A grades in high-credit subjects\n2️⃣ Use the GPA Calculator to track your progress\n3️⃣ Don't miss quizzes - they add up quickly\n4️⃣ Participate in class - some teachers give marks\n5️⃣ Review past papers before exams\n\n📊 Formula: GPA = Sum(Grade Points × Credits) / Total Credits";
    }
    else if (msg.contains('pomodoro') || msg.contains('timer') || msg.contains('focus')) {
      return "⏱️ Pomodoro Technique Guide:\n\n1️⃣ Choose ONE task to focus on\n2️⃣ Set timer to 25 minutes\n3️⃣ Work with FULL focus until timer rings\n4️⃣ Take a 5-minute break\n5️⃣ After 4 sessions, take a 15-30 min break\n\n🔥 Benefits: Better focus, less procrastination, more energy!\n\nUse the Pomodoro Timer in this app!";
    }
    else if (msg.contains('schedule') || msg.contains('timetable') || msg.contains('plan')) {
      return "📅 Study schedule tips:\n\n1️⃣ Add your class timetable in the Timetable screen\n2️⃣ Study hardest subjects when you're most alert\n3️⃣ Leave buffer time between study sessions\n4️⃣ Keep weekends for revision and rest\n5️⃣ Review your planner every Sunday for the week ahead\n\n💡 Use the Study Planner to organize your week!";
    }
    else if (msg.contains('stress') || msg.contains('anxiety') || msg.contains('overwhelm')) {
      return "🌟 Dealing with study stress:\n\n1️⃣ Break your work into small manageable tasks\n2️⃣ Take regular breaks - don't study for hours non-stop\n3️⃣ Exercise for at least 30 mins daily\n4️⃣ Sleep 7-8 hours every night\n5️⃣ Talk to friends, family or teachers for support\n\n💪 Remember: One step at a time. You've got this!";
    }
    else if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return "Hello! 😊 Great to see you!\n\nHow can I help you today? You can ask me about:\n• Study tips\n• Assignment management\n• Attendance improvement\n• GPA calculation\n• Pomodoro technique\n• Study scheduling";
    }
    else if (msg.contains('thank')) {
      return "You're welcome! 😊🌟\n\nKeep studying hard and use all the features in this app to stay organized. You've got this! 💪\n\nFeel free to ask anything else!";
    }
    else {
      return "🤔 I'm not sure about that specific topic, but here's what I can help with:\n\n• 📚 Study techniques\n• ✅ Attendance tips\n• 📋 Assignment management\n• 🎓 GPA improvement\n• ⏱️ Pomodoro focus tips\n• 📅 Study scheduling\n• 😰 Managing study stress\n\nTry asking about any of these topics!";
    }
  }

  /// Send message and generate AI response
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollDown();

    // Simulate AI thinking delay
    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: _generateResponse(text),
        isUser: false,
        time: DateTime.now(),
      ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFa29bfe), Color(0xFF6c5ce7)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Study Assistant', style: TextStyle(fontSize: 16)),
              Text('Always here to help',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ]),
      ),
      body: Column(
        children: [

          // ── Suggestion Chips ──────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _suggestions.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _sendMessage(_suggestions[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFa29bfe).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFa29bfe).withOpacity(0.4)),
                  ),
                  alignment: Alignment.center,
                  child: Text(_suggestions[i],
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6c5ce7))),
                ),
              ),
            ),
          ),

          // ── Chat Messages ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return _typingBubble();
                }
                final msg = _messages[i];
                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: _messageBubble(msg),
                );
              },
            ),
          ),

          // ── Input Bar ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: _sendMessage,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _sendMessage(_ctrl.text),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFFa29bfe), Color(0xFF6c5ce7)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /// Chat message bubble widget
  Widget _messageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: msg.isUser
              ? const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)])
              : null,
          color: msg.isUser
              ? null
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : null,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// Typing indicator bubble
  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(0),
          const SizedBox(width: 4),
          _dot(200),
          const SizedBox(width: 4),
          _dot(400),
        ]),
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF6c5ce7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}