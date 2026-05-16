import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Pomodoro Timer screen - focus study timer with sessions tracking
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});
  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Timer settings in minutes
  static const int _workMins   = 25;
  static const int _shortBreak = 5;
  static const int _longBreak  = 15;

  int _secondsLeft    = _workMins * 60;
  bool _isRunning     = false;
  bool _isBreak       = false;
  int _sessionsCount  = 0;
  int _totalSessions  = 4;
  Timer? _timer;

  /// Labels for each mode
  String get _modeLabel =>
      _isBreak ? (_sessionsCount % 4 == 0 ? 'Long Break ☕' : 'Short Break 😌')
               : 'Focus Time 🔥';

  /// Colors for each mode
  Color get _modeColor =>
      _isBreak ? const Color(0xFF26de81) : const Color(0xFFff7675);

  /// Total seconds for current mode
  int get _totalSeconds {
    if (!_isBreak) return _workMins * 60;
    return (_sessionsCount % 4 == 0 ? _longBreak : _shortBreak) * 60;
  }

  /// Progress from 0.0 to 1.0
  double get _progress => 1 - (_secondsLeft / _totalSeconds);

  /// Format seconds as MM:SS
  String get _timeString {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Start or pause the timer
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          _onTimerEnd();
        }
      });
    }
  }

  /// Handle timer completion - switch between work and break
  void _onTimerEnd() {
    if (!_isBreak) {
      // Work session done
      setState(() {
        _sessionsCount++;
        _isBreak    = true;
        _secondsLeft = (_sessionsCount % 4 == 0 ? _longBreak : _shortBreak) * 60;
        _isRunning  = false;
      });
    } else {
      // Break done - back to work
      setState(() {
        _isBreak    = false;
        _secondsLeft = _workMins * 60;
        _isRunning  = false;
      });
    }
  }

  /// Reset timer to beginning
  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning   = false;
      _isBreak     = false;
      _secondsLeft = _workMins * 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro Timer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            // ── Session dots ─────────────────────────────
            FadeInDown(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < (_sessionsCount % 4)
                        ? _modeColor
                        : Colors.grey.shade300,
                    boxShadow: i < (_sessionsCount % 4)
                        ? [BoxShadow(
                            color: _modeColor.withOpacity(0.5),
                            blurRadius: 6)]
                        : null,
                  ),
                )),
              ),
            ),
            const SizedBox(height: 8),
            Text('Session ${(_sessionsCount % 4) + 1} of 4',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 32),

            // ── Circular Timer ────────────────────────────
            FadeInUp(
              child: CircularPercentIndicator(
                radius: 130,
                lineWidth: 14,
                percent: _progress.clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_timeString,
                        style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: _modeColor)),
                    const SizedBox(height: 4),
                    Text(_modeLabel,
                        style: TextStyle(
                            fontSize: 14,
                            color: _modeColor,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                progressColor: _modeColor,
                backgroundColor: _modeColor.withOpacity(0.15),
                circularStrokeCap: CircularStrokeCap.round,
                animation: false,
              ),
            ),
            const SizedBox(height: 40),

            // ── Controls ──────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  GestureDetector(
                    onTap: _reset,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.refresh_rounded,
                          color: Colors.grey.shade600, size: 28),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Play/Pause button
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_modeColor, _modeColor.withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _modeColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Skip button
                  GestureDetector(
                    onTap: _onTimerEnd,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.skip_next_rounded,
                          color: Colors.grey.shade600, size: 28),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Stats Cards ───────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Row(children: [
                Expanded(child: _statCard(
                    'Sessions', '$_sessionsCount', Icons.check_circle_rounded,
                    const Color(0xFF6C63FF))),
                const SizedBox(width: 12),
                Expanded(child: _statCard(
                    'Focus Time', '${_sessionsCount * 25} min',
                    Icons.timer_rounded, const Color(0xFFff7675))),
                const SizedBox(width: 12),
                Expanded(child: _statCard(
                    'Breaks', '${_sessionsCount}',
                    Icons.coffee_rounded, const Color(0xFF26de81))),
              ]),
            ),
            const SizedBox(height: 24),

            // ── How to use ────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('How to use Pomodoro 💡',
                          style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 10),
                      _tip('🔴', 'Study for 25 minutes with full focus'),
                      _tip('🟢', 'Take a 5-minute break after each session'),
                      _tip('☕', 'Take 15-min break after 4 sessions'),
                      _tip('🔁', 'Repeat to maximize productivity'),
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

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        Text(label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _tip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: const TextStyle(fontSize: 13, color: Colors.grey))),
      ]),
    );
  }
}