import 'package:flutter/material.dart';
import 'package:kairos/src/api/models/session.dart';
import 'package:kairos/src/settings.dart';

class GlobalStates extends ChangeNotifier {
  bool isOffline = false;
  bool get isOfflineState => isOffline;

  set setOfflineState(bool value) {
    isOffline = value;
    notifyListeners();
  }

  bool shownOfflineSnackBar = false;
  bool get shownOfflineSnackBarState => shownOfflineSnackBar;

  set setShownOfflineSnackBarState(bool value) {
    shownOfflineSnackBar = value;
    notifyListeners();
  }

  // init as true to avoid showing snackbar on startup if already online
  bool shownOnlineSnackBar = true;
  bool get shownOnlineSnackBarState => shownOnlineSnackBar;

  set setShownOnlineSnackBarState(bool value) {
    shownOnlineSnackBar = value;
    notifyListeners();
  }

  List<Session> sessions = [];
  List<Session> get sessionsState => sessions;

  set setSessionsState(List<Session> value) {
    sessions = value;
    notifyListeners();
  }

  Settings settings = Settings(maxSessionDuration: 4);
  Settings get settingsState => settings;

  set setSettingsState(Settings value) {
    settings = value;
    notifyListeners();
  }
}
