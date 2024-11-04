import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kairos/src/api/google_sign_in_service.dart';
import 'package:kairos/src/api/models/project.dart';
import 'package:kairos/src/api/models/session.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/utils.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/shared_prefs.dart';
import 'package:kairos/src/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  final _sharedPrefs = SharedPrefs();
  int _duration = 3 * 3600;
  bool _isFocusMode = false;
  int _elapsedTime = 0;
  bool _isRunning = false;
  DateTime _startTime = currentTime();
  DateTime _endTime = currentTime();
  String _todaysFocus = formatSeconds(0);
  String _sessionId = const Uuid().v4();
  final FirebaseAuth _firebaseInstance = FirebaseAuth.instance;
  late String _userId;
  //TODO: fix late initialization of project error
  late Project _project;

  final CountDownController _controller = CountDownController();

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
    // TODO: Improve this
    if (_firebaseInstance.currentUser != null) {
      _userId = _firebaseInstance.currentUser!.uid;
    } else {
      // logout
      GoogleSignInService().logout();
    }
    _initMaxDuration();
    _initCurrentProject();
    loadProjects(context, _userId);
    _checkTodaysFocus();
    _checkActiveSession(context);
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkActiveSession(context);
      await _checkTodaysFocus();
    });
  }

  void _initCurrentProject() async {
    var project = await _sharedPrefs.getProject();
    if (project != null) {
      setState(() {
        _project = project;
      });
    } else {
      var projects = await ApiService.getProjects(_userId);
      if (projects.isNotEmpty) {
        var defaultProject =
            projects.firstWhere((element) => element.projectName == "Unset");
        setState(() {
          _project = defaultProject;
        });
        await _sharedPrefs.setProject(_project);
      }
    }
  }

  void _initMaxDuration() async {
    var maxSessionDuration = await _sharedPrefs.getMaxSessionDuration();
    if (maxSessionDuration != null) {
      _duration = maxSessionDuration * 3600;
    } else {
      _duration = 3 * 3600; // 3 hours default
    }
    debugPrint("max duration is $_duration");
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
        // NOTE: Offline
        // NOTE: Handling snackbar for offline
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
        // NOTE: Case 1 for max session limiter:
        // Handling session duration > maxSessionDuration when offline
        var maxSessionDuration = await _sharedPrefs.getMaxSessionDuration();
        var maxSessionDurationInSecs = maxSessionDuration! * 3600;
        if (session != null) {
          var duration = DateTime.now()
              .difference(DateTime.parse(session.startedAt))
              .inSeconds;
          if (duration > maxSessionDurationInSecs) {
            session.duration = maxSessionDurationInSecs;
            var startedAt = DateTime.parse(session.startedAt);
            // add maxSessionDurationInSecs to startedAt
            var endedAt =
                startedAt.add(Duration(seconds: maxSessionDurationInSecs));
            session.endedAt = endedAt.toString();
            var offlineSessions = await _sharedPrefs.getOfflineSessions();
            if (offlineSessions != null) {
              offlineSessions.add(session);
              await _sharedPrefs.setOfflineSessions(offlineSessions);
            }
            _sharedPrefs.setActiveSession(null);
            setState(() {
              _isRunning = false;
            });
            return false;
          }
        }

        if (session != null && !_isRunning) {
          // NOTE: Found active session in local storage and not running.. so start timer
          setState(() {
            _sessionId = session.sessionId;
            _startTime = DateTime.parse(session.startedAt);

            //TODO: handle this in countdown package
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
    // NOTE: Online
    var isActiveSession = false;

    // NOTE: Case 2 for max session limiter:
    // Handling session duration > maxSessionDuration when online and offline active session are same
    var offlineSession = await _sharedPrefs.getActiveSession();
    var onlineActiveSession =
        await ApiService.checkOnlineActiveSession(_userId);
    var maxSessionDuration = await _sharedPrefs.getMaxSessionDuration();
    var maxSessionDurationInSecs = maxSessionDuration! * 3600;
    if (offlineSession != null &&
        onlineActiveSession != null &&
        offlineSession.sessionId == onlineActiveSession.sessionId) {
      var duration = DateTime.now()
          .difference(DateTime.parse(offlineSession.startedAt))
          .inSeconds;
      if (duration > maxSessionDurationInSecs) {
        offlineSession.duration = maxSessionDurationInSecs;
        var startedAt = DateTime.parse(offlineSession.startedAt);
        // add maxSessionDurationInSecs to startedAt
        var endedAt =
            startedAt.add(Duration(seconds: maxSessionDurationInSecs));
        offlineSession.endedAt = endedAt.toString();
        await _sharedPrefs.setActiveSession(null);
        setState(() {
          _isRunning = false;
        });
        ApiService.updateSession(_userId, offlineSession);
        return false;
      }
    }

    globalStates.setOfflineState = false;
    var shownOnline = globalStates.shownOnlineSnackBar;
    if (!offline && !shownOnline) {
      // NOTE: Handling snackbar for back online
      globalStates.setShownOnlineSnackBarState = true;
      globalStates.setShownOfflineSnackBarState = false;
      showOnlineSnackBar(context);
    }
    // NOTE: check for online active session
    if (onlineActiveSession != null) {
      // prioritize offline active session
      // stop online active session
      if (offline) {
        // NOTE: Handling online and offline sessions for syncing
        // was offline till now
        globalStates.setSessionsState = await ApiService.getSessions(_userId);
        var offlineActiveSession = await _sharedPrefs.getActiveSession();
        if (offlineActiveSession != null &&
            offlineActiveSession.sessionId != onlineActiveSession.sessionId) {
          await _sharedPrefs.setActiveSession(offlineActiveSession);
          var alreadyEndedInOffline = false;
          // find online session in offline sessions
          // NOTE: offline sessions in local storage is cache of sessions that were not uploaded to server
          // once they are uploaded, they are removed from local storage
          var offlineSessions = await _sharedPrefs.getOfflineSessions();
          if (offlineSessions != null) {
            // already ended in offline
            for (var session in offlineSessions) {
              if (session.sessionId == onlineActiveSession.sessionId) {
                alreadyEndedInOffline = true;
                onlineActiveSession.endedAt = session.endedAt;
                onlineActiveSession.duration = session.duration;
                await ApiService.updateSession(_userId, onlineActiveSession);
                return true;
              }
            }
          }
          if (!alreadyEndedInOffline) {
            // ending old active online session and adding new offline active session if not already present in online else update
            onlineActiveSession.endedAt = currentTime().toString();
            var duration = DateTime.now().difference(_startTime).inSeconds;
            onlineActiveSession.duration = duration;
            await ApiService.updateSession(_userId, onlineActiveSession);
            var onlineSessions = await ApiService.getSessions(_userId);
            if (onlineSessions.any((element) =>
                element.sessionId == onlineActiveSession.sessionId)) {
              await ApiService.updateSession(_userId, offlineActiveSession);
            } else {
              await ApiService.addSession(_userId, offlineActiveSession);
            }
            globalStates.setOfflineState = false;
            return true;
          }
        }
      }
      // NOTE: no offline active session found so set active session to online active session
      await _sharedPrefs.setActiveSession(onlineActiveSession);
      // ensure elapsed time is always correct
      setState(() {
        _sessionId = onlineActiveSession.sessionId;
        _startTime = DateTime.parse(onlineActiveSession.startedAt);
        //TODO: handle this in countdown package
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
      // NOTE: no online active session found so check for offline active session
      var session = await _sharedPrefs.getActiveSession();
      //if it was just offline check if there is an offline active session
      if (session != null && offline) {
        // ensure this session is not already cancelled in online
        var onlineSessions = await ApiService.getSessions(_userId);
        // await _sharedPrefs.setOfflineStatus(false);
        globalStates.setOfflineState = false;
        // NOTE: if offline active session is not already in online sessions, add it
        if (!onlineSessions
            .any((element) => element.sessionId == session.sessionId)) {
          await ApiService.addSession(_userId, session);
          isActiveSession = true;
        } else {
          // NOTE: if offline active session is already cancelled in online, remove it
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
    _controller.reset();
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
          projectId: _project.projectId,
          startedAt: _startTime.toString(),
          endedAt: _endTime.toString(),
          duration: duration);
      try {
        await ApiService.updateSession(_userId, session);
      } catch (e) {
        // NOTE: if failed to update session on server, store offline
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
    _controller.start();
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
        projectId: _project.projectId,
        startedAt: _startTime.toString(),
        duration: 0);
    try {
      await ApiService.addSession(_userId, session);
    } catch (e) {
      // NOTE: if failed to add session on server, store offline
      globalStates.setOfflineState = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to add session on server storing offline")),
      );
    }
    SharedPrefs().setActiveSession(session);
    //NOTE: not needed since its done in countdown package
    //   Timer.periodic(const Duration(milliseconds: 500), (timer) {
    //     if (!_isRunning) {
    //       setState(() {
    //         _elapsedTime = 0;
    //       });
    //       timer.cancel();
    //     }
    //     if (session.endedAt != null) {
    //       timer.cancel();
    //     }
    //     // var maxSessionDuration = await _sharedPrefs.getMaxSessionDuration();
    //     // var maxSessionDurationInSecs = maxSessionDuration! * 3600;
    //     // if (_elapsedTime >= maxSessionDurationInSecs) {
    //     //   timer.cancel();
    //     // }
    //     setState(() {
    //       _elapsedTime++;
    //     });
    //   });
  }

  void _modalTap(String projectId, BuildContext bottomSheetContext) {
    Navigator.of(bottomSheetContext).pop();
    setState(() {
      _project = getProject(context, projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) => Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
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
                              color: Colors.white,
                            ),
                          ),
                          // const SizedBox(height: 10),
                          CircularCountDownTimer(
                            // Countdown total duration in Seconds.
                            //TODO: in stopwatch mode.. use max duration.. i.e 3 hrs
                            duration: _duration,

                            // Countdown initial elapsed Duration in Seconds.
                            initialDuration: 0,

                            // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                            controller: _controller,

                            // Width of the Countdown Widget.
                            width: MediaQuery.of(context).size.width / 2,

                            // Height of the Countdown Widget.
                            height: MediaQuery.of(context).size.height / 2,

                            // Ring Color for Countdown Widget.
                            ringColor: const Color(0xFF4A4462),

                            // Ring Gradient for Countdown Widget.
                            ringGradient: null,

                            // Filling Color for Countdown Widget.
                            fillColor: Colors.purpleAccent[100]!,

                            // Filling Gradient for Countdown Widget.
                            fillGradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.tertiary,
                              ],
                              stops: const [0.0, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),

                            // Background Color for Countdown Widget.
                            backgroundColor: null,

                            // Background Gradient for Countdown Widget.
                            backgroundGradient: null,

                            // Border Thickness of the Countdown Ring.
                            strokeWidth: 20.0,

                            // Begin and end contours with a flat edge and no extension.
                            strokeCap: StrokeCap.round,

                            // Text Style for Countdown Text.
                            textStyle: const TextStyle(
                              fontSize: 33.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),

                            // Format for the Countdown Text.
                            textFormat: CountdownTextFormat.S,

                            // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                            isReverse: false,

                            // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                            isReverseAnimation: false,

                            // Handles visibility of the Countdown Text.
                            isTimerTextShown: true,

                            // Handles the timer start.
                            autoStart: false,

                            // This Callback will execute when the Countdown Starts.
                            onStart: () {
                              // Here, do whatever you want
                              debugPrint('Countdown Started');
                            },

                            // This Callback will execute when the Countdown Ends.
                            onComplete: () {
                              // Here, do whatever you want
                              _elapsedTime++;
                              _resetTimer();
                              debugPrint('Countdown Ended');
                            },

                            timeFormatterFunction: (_, duration) {
                              return formatSeconds(duration.inSeconds);
                            },

                            // This Callback will execute when the Countdown Changes.
                            onChange: (String timeStamp) {
                              // Here, do whatever you want
                              _elapsedTime = parseSeconds(timeStamp);
                              debugPrint('Countdown Changed $_elapsedTime');
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              WoltModalSheet.show(
                                context: context,
                                pageListBuilder: (bottomSheetContext) => [
                                  SliverWoltModalSheetPage(
                                    mainContentSliversBuilder: (context) => [
                                      SliverList.builder(
                                        itemBuilder: (context, index) {
                                          final reversedIndex = globalStates
                                                  .projectsState.length -
                                              1 -
                                              index;
                                          var project = globalStates
                                              .projectsState[reversedIndex];
                                          return ListTile(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        color: Colors.grey),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    project.projectName,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                _modalTap(project.projectId,
                                                    bottomSheetContext);
                                              });
                                        },
                                        itemCount:
                                            globalStates.projectsState.length,
                                      ),
                                    ],
                                    stickyActionBar: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/projects');
                                      },
                                      child: const Text('Manage Projects',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                    ),
                                    // topBarTitle: const Text('Choose Project'),
                                    // isTopBarLayerAlwaysVisible: true,
                                    //TODO: remove this and add space at the bottom of list if the last is small
                                    forceMaxHeight: true,
                                  )
                                ],
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                  left: 18,
                                  right: 18,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  _project.projectName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                  left: _isRunning ? 40 : 50,
                                  right: _isRunning ? 40 : 50,
                                ),
                              ),
                              backgroundColor: !_isRunning
                                  ? WidgetStateProperty.all(
                                      Theme.of(context).colorScheme.primary,
                                    )
                                  : WidgetStateProperty.all(
                                      Theme.of(context).colorScheme.tertiary,
                                    ),
                            ),
                            onPressed: () {
                              _isRunning ? _resetTimer() : _startTimer(context);
                            },
                            child: Text(
                              _isRunning ? "Give up" : "Start",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
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
