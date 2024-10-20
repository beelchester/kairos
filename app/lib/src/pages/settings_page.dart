import 'package:flutter/material.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/shared_prefs.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/widgets/drawer.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _sharedPrefs = SharedPrefs();
  int? _maxSessionDuration;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    var maxSessionDuration = await _sharedPrefs.getMaxSessionDuration();
    setState(() {
      _maxSessionDuration = maxSessionDuration;
    });
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
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Max Session Duration',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 10),
            Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.deepPurpleAccent,
                ),
                child: DropdownButton<int>(
                  value: _maxSessionDuration,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _maxSessionDuration = newValue;
                      });
                      _sharedPrefs.setMaxSessionDuration(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 1,
                        child: Text(
                          '1 hour',
                          style: TextStyle(color: Colors.white),
                        )),
                    DropdownMenuItem(
                        value: 2,
                        child: Text(
                          '2 hours',
                          style: TextStyle(color: Colors.white),
                        )),
                    DropdownMenuItem(
                        value: 3,
                        child: Text(
                          '3 hours',
                          style: TextStyle(color: Colors.white),
                        )),
                    DropdownMenuItem(
                        value: 4,
                        child: Text(
                          '4 hours',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                )),
          ],
        )),
      )
    ]);
  }
}
