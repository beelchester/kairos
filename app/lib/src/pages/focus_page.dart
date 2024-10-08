import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kairos/src/api/models/session.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/utils.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/shared_prefs.dart';
import 'package:kairos/src/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
  String _todaysFocus = formatSeconds(0);
  String _sessionId = const Uuid().v4();
  // final String _userId = const Uuid().v4();
  final String _userId = "00000000-0000-0000-0000-000000000000".toString();
  final _sharedPrefs = SharedPrefs();

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
    _checkActiveSession(context);
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkActiveSession(context);
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
        var offlineSessions = await _sharedPrefs.getOfflineSessions();
        if (offlineSessions != null && offlineSessions.isNotEmpty) {
          var total = 0;
          for (var session in offlineSessions) {
            // if session is today
            if (session.startedAt.substring(0, 10) ==
                currentTime().toString().substring(0, 10)) {
              total += session.duration;
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
  Future<bool> _checkActiveSession(BuildContext context) async {
    var globalStates = Provider.of<GlobalStates>(context, listen: false);
    var offline = globalStates.isOfflineState;
    try {
      var health = await ApiService.checkHealth();
      if (!health) {
        if (!offline) {
          // was online till now
          var shownOffline = globalStates.shownOfflineSnackBar;
          if (!shownOffline) {
            showOfflineSnackBar(context);
            setState(() {
              globalStates.setShownOfflineSnackBarState = true;
              globalStates.setShownOnlineSnackBarState = false;
            });
          }
          globalStates.setOfflineState = true;
        }
        var session = await _sharedPrefs.getActiveSession();
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

    globalStates.setOfflineState = false;
    var shownOnline = globalStates.shownOnlineSnackBar;
    if (!offline && !shownOnline) {
      globalStates.setShownOnlineSnackBarState = true;
      globalStates.setShownOfflineSnackBarState = false;
      showOnlineSnackBar(context);
    }
    // check for online active session
    var activeSession = await ApiService.checkOnlineActiveSession(_userId);
    if (activeSession != null) {
      // prioritize offline active session
      // stop online active session
      if (offline) {
        // was offline till now
        globalStates.setSessionsState = await ApiService.getSessions(_userId);
        var offlineActiveSession = await _sharedPrefs.getActiveSession();
        if (offlineActiveSession != null) {}
        if (offlineActiveSession != null &&
            offlineActiveSession.sessionId != activeSession.sessionId) {
          await _sharedPrefs.setActiveSession(offlineActiveSession);
          var alreadyEndedInOffline = false;
          // find online session in offline sessions
          var offlineSessions = await _sharedPrefs.getOfflineSessions();
          if (offlineSessions != null) {
            // already ended in offline
            for (var session in offlineSessions) {
              if (session.sessionId == activeSession.sessionId &&
                  session.duration != null) {
                alreadyEndedInOffline = true;
                activeSession.endedAt = session.endedAt;
                activeSession.duration = session.duration;
                await ApiService.updateSession(_userId, activeSession);
                return true;
              }
            }
          }
          if (!alreadyEndedInOffline) {
            // ending old active online session and adding new offline active session if not already present in online else update
            activeSession.endedAt = currentTime().toString();
            var duration = DateTime.now().difference(_startTime).inSeconds;
            activeSession.duration = duration;
            await ApiService.updateSession(_userId, activeSession);
            var onlineSessions = await ApiService.getSessions(_userId);
            if (onlineSessions.any(
                (element) => element.sessionId == activeSession.sessionId)) {
              await ApiService.updateSession(_userId, offlineActiveSession);
            } else {
              await ApiService.addSession(_userId, offlineActiveSession);
            }
            globalStates.setOfflineState = false;
            return true;
          }
        }
      }
      // no offline active session found
      await _sharedPrefs.setActiveSession(activeSession);
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
      var session = await _sharedPrefs.getActiveSession();
      //if it was just offline check if there is an offline active session
      if (session != null && offline) {
        // ensure this session is not already cancelled in online
        var onlineSessions = await ApiService.getSessions(_userId);
        // await _sharedPrefs.setOfflineStatus(false);
        globalStates.setOfflineState = false;
        if (!onlineSessions
            .any((element) => element.sessionId == session.sessionId)) {
          await ApiService.addSession(_userId, session);
          isActiveSession = true;
        } else {
          isActiveSession = false;
          await _sharedPrefs.setActiveSession(null);
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

  /// Used to sync sessions across devices
  Future<void> _handleSync() async {
    // check for offline sessions
    var offlineSessions = await _sharedPrefs.getOfflineSessions();
    if (offlineSessions != null && offlineSessions.isNotEmpty) {
      var onlineSessions = await ApiService.getSessions(_userId);
      // send the offline session if it is not already in onlineSessions
      for (var session in offlineSessions) {
        if (!onlineSessions
            .any((element) => element.sessionId == session.sessionId)) {
          try {
            ApiService.addSession(_userId, session);
            // remove the session that was successfully uploaded from the offline sessions
            offlineSessions.remove(session);
            await _sharedPrefs.setOfflineSessions(offlineSessions);
          } catch (e) {}
        }
      }
    }
  }

  Future<void> _resetTimer() async {
    setState(() {
      _isRunning = false;
      _endTime = currentTime();
      _elapsedTime = 0;
    });
    var activeSession = await _sharedPrefs.getActiveSession();

    if (activeSession != null) {
      var duration = _endTime.difference(_startTime).inSeconds;
      var session = Session(
          sessionId: _sessionId,
          userId: _userId,
          startedAt: _startTime.toString(),
          endedAt: _endTime.toString(),
          duration: duration);
      try {
        await ApiService.updateSession(_userId, session);
      } catch (e) {
        var offlineSessions = await _sharedPrefs.getOfflineSessions();
        if (offlineSessions != null) {
          offlineSessions.add(session);
        } else {
          offlineSessions = [session];
        }
        await _sharedPrefs.setOfflineSessions(offlineSessions);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Failed to update session on server storing offline")),
        );
      }
      await _sharedPrefs.setActiveSession(null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to find active session")),
      );
    }
    _checkTodaysFocus();
  }

  Future<void> _startTimer(BuildContext context) async {
    var globalStates = Provider.of<GlobalStates>(context, listen: false);
    var runningOnOtherDevice = await _checkActiveSession(context);
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
      _sessionId = const Uuid().v4();
    });
    var session = Session(
        sessionId: _sessionId,
        userId: _userId,
        startedAt: _startTime.toString(),
        duration: 0);
    try {
      await ApiService.addSession(_userId, session);
    } catch (e) {
      globalStates.setOfflineState = true;
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
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) => Scaffold(
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
                              _isRunning ? _resetTimer() : _startTimer(context);
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
            ));
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
