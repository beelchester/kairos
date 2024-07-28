import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/api/models/session.dart';
import 'package:kairos/src/utils.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/widgets/drawer.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<Session> _sessions = [];
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    var sessions = await ApiService.getSessions('user1');
    if (sessions != null) {
      setState(() {
        _sessions = sessions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(),
        drawer: const DrawerWidget(),
        backgroundColor: Colors.deepPurple,
        body: ListView.builder(
          itemCount: _sessions.length,
          itemBuilder: (context, index) {
            return _sessionCard(_sessions[index]);
          },
        ));
  }

  Widget _sessionCard(Session session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              formatSeconds(int.parse(session.duration!)),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  session.startedAt.substring(11, 16),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'to',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  session.endedAt!.substring(11, 16),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              session.startedAt.substring(0, 11),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
