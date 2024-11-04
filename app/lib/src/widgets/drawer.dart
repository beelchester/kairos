import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  static final User? _user = FirebaseAuth.instance.currentUser;
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      child: Column(
        children: [
          DrawerHeader(
              child: Column(
            children: [
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  _user?.photoURL ?? '',
                  height: 60,
                  width: 60,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '${_user?.displayName}',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          )),
          const SizedBox(height: 30),
          ListTile(
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/focus');
            },
          ),
          ListTile(
            title: const Text('Stats', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/stats');
            },
          ),
          ListTile(
            title:
                const Text('Timeline', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/timeline');
            },
          ),
          const ListTile(
            // grey out the option
            title: Text('Leaderboard', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            // grey out the option
            title:
                const Text('Projects', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/projects');
            },
          ),
          if (Platform.isIOS || Platform.isAndroid)
            const ListTile(
              // grey out the option
              title: Text('Block Apps', style: TextStyle(color: Colors.grey)),
            ),
          ListTile(
            // grey out the option
            title:
                const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                Text(
                  'Kairos',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Version 0.0.1',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Made with ❤️ by beelchester',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
