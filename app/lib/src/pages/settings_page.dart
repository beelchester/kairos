import 'package:flutter/material.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/widgets/drawer.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) => Scaffold(
            appBar: const AppBarWidget(),
            drawer: const DrawerWidget(),
            backgroundColor: Colors.deepPurple,
            body: _settingsList(globalStates)));
  }

  Widget _settingsList(GlobalStates globalState) {
    return ListView(padding: const EdgeInsets.all(8), children: [
      Container(
        height: 50,
        color: Colors.black45,
        child: Center(
            child: Text(
          'Max Session Duration: ${globalState.settings.maxSessionDuration}',
          style: const TextStyle(color: Colors.white),
        )),
      )
    ]);
  }
}
