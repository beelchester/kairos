import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kairos/src/api/models/session.dart';
import 'package:kairos/src/widgets/menu_button.dart';
import 'package:kairos/src/utils.dart';
import 'package:kairos/src/api/api_service.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  bool _isFocusMode = false;
  int _elapsedTime = 0;
  bool _isRunning = false;
  DateTime _startTime = currentTime();
  DateTime _endTime = currentTime();
  String _sessionId = '0';
  static const String _userId = 'user1';

  void _toggleMode() {
    setState(() {
      _isFocusMode = !_isFocusMode;
    });
    if (_isFocusMode) {
      showNotAvailable(context);
    }
  }

  Future<void> _resetTimer() async {
    setState(() {
      _isRunning = false;
      _endTime = currentTime();
      _elapsedTime = 0;
    });
    var activeSession = await ApiService.checkActiveSession(_userId);
    if (activeSession != null) {
      var startedAt = DateTime.parse(activeSession.startedAt);
      var duration = _endTime.difference(startedAt).inSeconds;
      print("duration: $duration");
      var session = Session(
          sessionId: _sessionId,
          startedAt: _startTime.toString(),
          endedAt: _endTime.toString());
      try {
        await ApiService.updateSession(_userId, session);
      } catch (e) {
        print(e);
      }
    } else {
      print("Failed to find active session for $_userId");
    }
  }

  Future<void> _startTimer() async {
    setState(() {
      _elapsedTime = 0;
      _isRunning = true;
      _startTime = currentTime();
      // random session id
      _sessionId = Random().nextInt(1000000).toString();
    });
    var session =
        Session(sessionId: _sessionId, startedAt: _startTime.toString());
    try {
      await ApiService.addSession(_userId, session);
    } catch (e) {
      print(e);
    }
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isRunning) {
        timer.cancel();
      }
      setState(() {
        _elapsedTime++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: const MenuButton(),
        title: _focusModeHandler(),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: const Row(
              children: [
                Icon(Icons.sports_score_rounded),
                SizedBox(width: 5),
                Text(
                  '1000',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: _isFocusMode
            ? const Text("Timer")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatTime(_elapsedTime),
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      _isRunning ? _resetTimer() : _startTimer();
                    },
                    child: Text(
                      _isRunning ? "Stop" : "Start",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _focusModeHandler() {
    return IconButton(
      onPressed: _toggleMode,
      icon: Icon(
        _isFocusMode ? Icons.query_builder_rounded : Icons.timer_rounded,
        color: Colors.black,
      ),
    );
  }
}