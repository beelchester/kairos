import 'package:flutter/material.dart';
import 'package:kairos/src/pages/focus_page.dart';
import 'package:kairos/src/pages/timeline_page.dart';
import 'package:kairos/src/utils.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.deepPurple,
      child: Column(
        children: [
          DrawerHeader(
            child: Text('Profile details'),
          ),
          const SizedBox(height: 30),
          ListTile(
            title: Text('Home', style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FocusPage()),
              );
            },
          ),
          ListTile(
            // grey out the option
            title: Text('Stats', style: const TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title:
                Text('Timeline', style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimelinePage()),
              );
            },
          ),
          ListTile(
            // grey out the option
            title:
                Text('Leaderboard', style: const TextStyle(color: Colors.grey)),
          ),
          ListTile(
            // grey out the option
            title: Text('Tags', style: const TextStyle(color: Colors.grey)),
          ),
          ListTile(
            // grey out the option
            title:
                Text('Block Apps', style: const TextStyle(color: Colors.grey)),
          ),
          ListTile(
            // grey out the option
            title: Text('Settings', style: const TextStyle(color: Colors.grey)),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                Text(
                  'Kairos',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Version 0.0.1',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Made with ❤️ by beelchester',
                  style: const TextStyle(
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
