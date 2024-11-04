import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/api/google_sign_in_service.dart';
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
  final FirebaseAuth _firebaseInstance = FirebaseAuth.instance;
  late String _userId;
  @override
  void initState() {
    super.initState();
    if (_firebaseInstance.currentUser != null) {
      _userId = _firebaseInstance.currentUser!.uid;
    } else {
      // logout
      GoogleSignInService().logout();
    }
    loadProjects(context, _userId);
    loadSessions(context, _userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) => Scaffold(
            appBar: const AppBarWidget(),
            drawer: const DrawerWidget(),
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: ListView.builder(
              itemCount: globalStates.sessionsState.length,
              itemBuilder: (context, index) {
                // Access elements from the end of the list by reversing the index
                //TODO: ensure the accuracy of this.. it should sort by the time not just day
                final reversedIndex =
                    globalStates.sessionsState.length - 1 - index;
                return _sessionCard(globalStates.sessionsState[reversedIndex]);
              },
            )));
  }

  Widget _sessionCard(Session session) {
    if (session.endedAt == null) {
      return const SizedBox();
    }
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              formatSeconds(session.duration),
              style: const TextStyle(
                fontSize: 24,
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
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'to',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 5),
                if (session.endedAt != null)
                  Text(
                    session.endedAt!.substring(11, 16),
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                session.startedAt.substring(0, 10),
                style: const TextStyle(
                  fontSize: 15,
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
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    session.endedAt!.substring(0, 10),
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ])
            ]),
            Row(
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
                  getProject(context, session.projectId).projectName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
