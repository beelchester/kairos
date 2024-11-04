import 'package:flutter/material.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/api/models/project.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/shared_prefs.dart';
import 'package:provider/provider.dart';

DateTime currentTime() {
  return DateTime.now().toUtc();
}

String formatTime(int milliseconds) {
  // milliseconds are in chunks of 500
  // so / 2 to get seconds
  var seconds = (milliseconds / 2).floor();
  return formatSeconds(seconds);
}

String formatSeconds(int seconds) {
  var minutes = (seconds / 60).floor();
  var hours = (minutes / 60).floor();
  minutes = minutes % 60;
  seconds = seconds % 60;
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

int parseSeconds(String secondsInput) {
  var parts = secondsInput.split(':');
  if (parts.length == 2) {
    var minutes = int.parse(parts[0]);
    var seconds = int.parse(parts[1]);
    return minutes * 60 + seconds;
  } else if (parts.length == 3) {
    var hours = int.parse(parts[0]);
    var minutes = int.parse(parts[1]);
    var seconds = int.parse(parts[2]);
    return hours * 3600 + minutes * 60 + seconds;
  }
  return 0;
}

void showNotAvailable(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Feature not available yet")),
  );
}

void showOfflineSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'You are offline',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    ),
  );
}

void showOnlineSnackBar(BuildContext context) {
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

Future<void> loadProjects(BuildContext context, String userId) async {
  var globalStates = Provider.of<GlobalStates>(context, listen: false);
  try {
    var projects = await ApiService.getProjects(userId);
    globalStates.setProjectsState = projects;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Project getProject(BuildContext context, String projectId) {
  var globalStates = Provider.of<GlobalStates>(context, listen: false);
  var project = globalStates.projectsState
      .firstWhere((project) => project.projectId == projectId);
  return project;
}

Future<void> loadSessions(BuildContext context, String userId) async {
  var globalStates = Provider.of<GlobalStates>(context, listen: false);
  try {
    var sessions = await ApiService.getSessions(userId);
    globalStates.setSessionsState = sessions;
  } catch (e) {
    var offlineSessions = await SharedPrefs().getOfflineSessions();
    if (offlineSessions != null) {
      globalStates.setSessionsState = offlineSessions;
    }
  }
}
