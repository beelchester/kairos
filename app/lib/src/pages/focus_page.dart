import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kairos/src/api/models/session.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/utils.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/shared_prefs.dart';
import 'package:kairos/src/widgets/drawer.dart';

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
  String _todaysFocus = formatSeconds(0);
  static const String _userId = 'user1';
  final _globalState = SharedPrefs();
  bool? _shownOffline;
  bool? _shownOnline = false;

  void _toggleMode() {
    setState(() {
      _isFocusMode = !_isFocusMode;
    });
    if (_isFocusMode) {
      showNotAvailable(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkTodaysFocus();
    _checkActiveSession();
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkActiveSession();
      await _checkTodaysFocus();
    });
  }

  Future<void> _checkTodaysFocus() async {
    if (!_isRunning) {
      try {
        var total = await ApiService.getTodaysFocusTime(_userId);
        setState(() {
          _todaysFocus = total;
        });
      } catch (e) {
        var offlineSessions = await _globalState.getOfflineSessions();
        if (offlineSessions != null && offlineSessions.isNotEmpty) {
          var total = 0;
          for (var session in offlineSessions) {
            // if session is today
            if (session.startedAt.substring(0, 10) ==
                currentTime().toString().substring(0, 10)) {
              if (session.duration != null) {
                total += int.parse(session.duration!);
              }
            }
          }
          setState(() {
            _todaysFocus = formatSeconds(total);
          });
        }
      }
    }
  }

  // NOTE: Main function used for syncing data with server, runs every 10 seconds
  Future<bool> _checkActiveSession() async {
    var offline = await _globalState.getOfflineStatus();
    try {
      var health = await ApiService.checkHealth();
      if (!health) {
        if (offline == null || !offline) {
          if (_shownOffline == null || _shownOffline == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'You are offline',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _shownOffline = true;
              _shownOnline = null;
            });
          }
          SharedPrefs().setOfflineStatus(true);
        }
        var session = await _globalState.getActiveSession();
        if (session != null && !_isRunning) {
          setState(() {
            _sessionId = session.sessionId;
            _startTime = DateTime.parse(session.startedAt);
            _elapsedTime =
                (DateTime.now().difference(_startTime).inSeconds) * 2;
            _isRunning = true;
          });
          Timer.periodic(const Duration(milliseconds: 500), (timer) {
            if (!_isRunning) {
              timer.cancel();
            }
            setState(() {
              _elapsedTime++;
            });
          });
          return true;
        }
        return false;
      }
    } catch (e) {
      return false;
    }
    // state online
    var isActiveSession = false;

    await _globalState.setOfflineStatus(false);
    if (offline != null && !offline && _shownOnline == null) {
      _shownOnline = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You are back online',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
    // check for online active session
    var activeSession = await ApiService.checkOnlineActiveSession(_userId);
    if (activeSession != null) {
      // prioritize offline active session
      // stop online active session
      if (offline != null && offline) {
        var offlineActiveSession = await _globalState.getActiveSession();
        if (offlineActiveSession != null) {}
        if (offlineActiveSession != null &&
            offlineActiveSession.sessionId != activeSession.sessionId) {
          await _globalState.setActiveSession(offlineActiveSession);
          var alreadyEndedInOffline = false;
          // find online session in offline sessions
          var offlineSessions = await _globalState.getOfflineSessions();
          if (offlineSessions != null) {
            // already ended in offline
            for (var session in offlineSessions) {
              if (session.sessionId == activeSession.sessionId &&
                  session.duration != null) {
                alreadyEndedInOffline = true;
                activeSession.endedAt = session.endedAt;
                activeSession.duration = session.duration;
                await ApiService.updateSession(_userId, activeSession);
                await ApiService.addSession(_userId, offlineActiveSession);
                return true;
              }
            }
          }
          if (!alreadyEndedInOffline) {
            // ending online session
            activeSession.endedAt = currentTime().toString();
            var duration = DateTime.now().difference(_startTime).inSeconds;
            activeSession.duration = duration.toString();
            await ApiService.updateSession(_userId, activeSession);
            await ApiService.addSession(_userId, offlineActiveSession);
            await _globalState.setOfflineStatus(false);
            return true;
          }
        }
      }
      await _globalState.setActiveSession(activeSession);
      // ensure elapsed time is always correct
      setState(() {
        _sessionId = activeSession.sessionId;
        _startTime = DateTime.parse(activeSession.startedAt);
        _elapsedTime = (DateTime.now().difference(_startTime).inSeconds) * 2;
      });
      if (!_isRunning) {
        setState(() {
          _isRunning = true;
        });
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
          if (!_isRunning) {
            timer.cancel();
          }
          setState(() {
            _elapsedTime++;
          });
        });
      }
      isActiveSession = true;
    } else {
      var session = await _globalState.getActiveSession();
      if (session != null) {
        // ensure this session is not already cancelled in online
        var onlineSessions = await ApiService.getSessions(_userId);
        await _globalState.setOfflineStatus(false);
        if (!onlineSessions
            .any((element) => element.sessionId == session.sessionId)) {
          await ApiService.addSession(_userId, session);
          isActiveSession = true;
        } else {
          isActiveSession = false;
          await _globalState.setActiveSession(null);
        }
      } else {
        setState(() {
          _isRunning = false;
          _elapsedTime = 0;
        });
      }
      isActiveSession = false;
    }
    _handleSync();
    return isActiveSession;
  }

  Future<void> _handleSync() async {
    var offlineSessions = await _globalState.getOfflineSessions();
    if (offlineSessions != null && offlineSessions.isNotEmpty) {
      var onlineSessions = await ApiService.getSessions(_userId);
      // send the offline session if it is not already in onlineSessions
      var onlineSessionsToAdd = <Session>[];
      for (var session in offlineSessions) {
        if (!onlineSessions
            .any((element) => element.sessionId == session.sessionId)) {
          onlineSessionsToAdd.add(session);
        }
      }
      if (onlineSessionsToAdd.isNotEmpty) {
        try {
          ApiService.updateSessions(_userId, onlineSessionsToAdd);
          await _globalState.setOfflineSessions([]);
        } catch (e) {}
      }
    }
  }

  Future<void> _resetTimer() async {
    setState(() {
      _isRunning = false;
      _endTime = currentTime();
      _elapsedTime = 0;
    });
    var activeSession = await _globalState.getActiveSession();

    if (activeSession != null) {
      var duration = _endTime.difference(_startTime).inSeconds;
      var session = Session(
          sessionId: _sessionId,
          startedAt: _startTime.toString(),
          endedAt: _endTime.toString(),
          duration: duration.toString());
      try {
        await ApiService.updateSession(_userId, session);
      } catch (e) {
        var offlineSessions = await _globalState.getOfflineSessions();
        if (offlineSessions != null) {
          offlineSessions.add(session);
        } else {
          offlineSessions = [session];
        }
        await _globalState.setOfflineSessions(offlineSessions);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Failed to update session on server storing offline")),
        );
      }
      await _globalState.setActiveSession(null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to find active session")),
      );
    }
    _checkTodaysFocus();
  }

  Future<void> _startTimer() async {
    var runningOnOtherDevice = await _checkActiveSession();
    if (runningOnOtherDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session already running")),
      );
      return;
    }
    setState(() {
      _elapsedTime = 0;
      _isRunning = true;
      _startTime = currentTime();
      // random session id
      _sessionId = Random().nextInt(1000000000).toString();
    });
    var session =
        Session(sessionId: _sessionId, startedAt: _startTime.toString());
    try {
      await ApiService.addSession(_userId, session);
    } catch (e) {
      SharedPrefs().setOfflineStatus(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to add session on server storing offline")),
      );
    }
    SharedPrefs().setActiveSession(session);
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
      drawer: const DrawerWidget(),
      appBar: const AppBarWidget(),
      body: Center(
        child: _isFocusMode
            ? const Text("Timer")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _todaysFocus,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
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
