import 'dart:convert';

import 'package:kairos/src/api/models/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();
  factory SharedPrefs() => _instance;

  SharedPrefs._internal();

  Future<void> setMaxSessionDuration(int maxSessionDuration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // NOTE: maxSessionDuration is in hours
    // Max session duration is 4 hours
    // if (maxSessionDuration != 0 && maxSessionDuration <= 4) {
    //TODO: remove
    if (maxSessionDuration <= 4) {
      await prefs.setInt('maxSessionDuration', maxSessionDuration);
    }
  }

  Future<int?> getMaxSessionDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var maxSessionDuration = prefs.getInt('maxSessionDuration');
    if (maxSessionDuration != null) {
      return maxSessionDuration;
    } else {
      // Default max session duration is 2 hours
      await prefs.setInt('maxSessionDuration', 2);
      return 2;
    }
  }

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
