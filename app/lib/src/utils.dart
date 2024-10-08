import 'package:flutter/material.dart';

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
