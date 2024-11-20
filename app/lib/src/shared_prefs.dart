import 'dart:convert';

import 'package:kairos/src/api/models/project.dart';
import 'package:kairos/src/api/models/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();
  factory SharedPrefs() => _instance;

  SharedPrefs._internal();

  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', loggedIn);
  }

  Future<bool> getLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  Future<void> setMaxSessionDuration(int maxSessionDuration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //NOTE: Max session duration is 3 hours
    if (maxSessionDuration != 0 && maxSessionDuration <= 3) {
      await prefs.setInt('maxSessionDuration', maxSessionDuration);
    }
  }

  Future<int?> getMaxSessionDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var maxSessionDuration = prefs.getInt('maxSessionDuration');
    if (maxSessionDuration != null) {
      return maxSessionDuration;
    } else {
      // Default max session duration is 3 hours
      await prefs.setInt('maxSessionDuration', 3);
      return 3;
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

  Future<void> setProject(Project? project) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (project != null) {
      var projectString = jsonEncode(project);
      await prefs.setString('project', projectString);
    }
  }

  Future<Project?> getProject() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var projectString = prefs.getString('project');
    if (projectString != null) {
      return Project.fromJson(jsonDecode(projectString));
    }
    return null;
  }
}
