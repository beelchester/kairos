import 'package:flutter/material.dart';
import 'package:kairos/src/api/google_sign_in_service.dart';
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: _settingsList(globalStates)));
  }

  Widget _settingsList(GlobalStates globalState) {
    return ListView(padding: const EdgeInsets.all(8), children: [
      Container(
        height: 50,
        color: Colors.black45,
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              'Max Session Duration',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 10),
            Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Theme.of(context).colorScheme.surfaceBright,
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
                        ))
                  ],
                )),
          ],
        )),
      ),
      //logout button
      const SizedBox(height: 10),
      SizedBox(
        height: 50,
        child: Center(
            child: ElevatedButton(
          onPressed: () {
            GoogleSignInService().logout();
            Navigator.of(context).pushReplacementNamed('/');
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          child: const Text("Logout", style: TextStyle(color: Colors.black)),
        )),
      )
    ]);
  }
}
