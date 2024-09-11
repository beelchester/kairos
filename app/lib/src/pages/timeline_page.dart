import 'package:flutter/material.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/api/models/session.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/utils.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/widgets/drawer.dart';
import 'package:provider/provider.dart';

import '../shared_prefs.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _sharedPrefs = SharedPrefs();
  @override
  void initState() {
    super.initState();
    _loadSessions(context);
  }

  Future<void> _loadSessions(BuildContext context) async {
    var globalStates = Provider.of<GlobalStates>(context, listen: false);
    try {
      var sessions =
          await ApiService.getSessions('00000000-0000-0000-0000-000000000000');
      globalStates.setSessionsState = sessions;
    } catch (e) {
      var offlineSessions = await _sharedPrefs.getOfflineSessions();
      if (offlineSessions != null) {
        globalStates.setSessionsState = offlineSessions;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) => Scaffold(
            appBar: const AppBarWidget(),
            drawer: const DrawerWidget(),
            backgroundColor: Colors.deepPurple,
            body: ListView.builder(
              itemCount: globalStates.sessionsState.length,
              itemBuilder: (context, index) {
                return _sessionCard(globalStates.sessionsState[index]);
              },
            )));
  }

  Widget _sessionCard(Session session) {
    if (session.duration == null || session.endedAt == null) {
      return const SizedBox();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              formatSeconds(session.duration),
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
                const Text(
                  'to',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
                if (session.endedAt != null)
                  Text(
                    session.endedAt!.substring(11, 16),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                session.startedAt.substring(0, 10),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              if (session.endedAt!.substring(0, 10) !=
                  session.startedAt.substring(0, 10))
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(width: 5),
                  const Text(
                    'to',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    session.endedAt!.substring(0, 10),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ])
            ]),
          ],
        ),
      ),
    );
  }
}
