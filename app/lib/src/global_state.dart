import 'dart:convert';

import 'package:kairos/src/api/models/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  factory GlobalState() => _instance;

  GlobalState._internal();

  Future<void> setActiveSession(Session? session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (session != null) {
      var sessionString = jsonEncode(session);
      await prefs.setString('activeSession', sessionString);
    } else {
      await prefs.remove('activeSession');
    }
  }

  Future<Session?> getActiveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var sessionString = prefs.getString('activeSession');
    if (sessionString != null) {
      return Session.fromJson(jsonDecode(sessionString));
    }
    return null;
  }

  Future<void> setOfflineStatus(bool offline) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offline', offline);
  }

  Future<bool?> getOfflineStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('offline');
  }

  Future<void> setOfflineSessions(List<Session>? sessions) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var sessionsString = jsonEncode(sessions);
    await prefs.setString('userSessions', sessionsString);
  }

  Future<List<Session>?> getOfflineSessions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var sessionsString = prefs.getString('userSessions');
    if (sessionsString != null) {
      return (jsonDecode(sessionsString) as List<dynamic>)
          .map((e) => Session.fromJson(e))
          .toList();
    }
    return null;
  }
}
