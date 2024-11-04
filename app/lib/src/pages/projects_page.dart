import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/api/google_sign_in_service.dart';
import 'package:kairos/src/api/models/project.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/widgets/drawer.dart';
import 'package:provider/provider.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
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
    _loadProjects(context);
  }

  Future<void> _loadProjects(BuildContext context) async {
    var globalStates = Provider.of<GlobalStates>(context, listen: false);
    try {
      var projects = await ApiService.getProjects(_userId);
      globalStates.setProjectsState = projects;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) => Scaffold(
              appBar: const AppBarWidget(),
              drawer: const DrawerWidget(),
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                      // make the listview take up the entire space available
                      child: ListView.builder(
                    itemCount: globalStates.projects.length,
                    itemBuilder: (context, index) {
                      // Access elements from the end of the list by reversing the index
                      final reversedIndex =
                          globalStates.projects.length - 1 - index;
                      return _projectCard(
                          globalStates.projectsState[reversedIndex]);
                    },
                  )),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Add Project',
                              style: TextStyle(color: Colors.black)),
                          SizedBox(width: 10),
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: Colors.black,
                          ),
                        ],
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ));
  }

  Widget _projectCard(Project project) {
    // ignore the default 'Unset' project
    // if (project.projectName == "Unset") {
    //   return const SizedBox();
    // }
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 16, bottom: 16, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.grey),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              project.projectName,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
