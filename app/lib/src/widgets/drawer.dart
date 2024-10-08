import 'package:flutter/material.dart';
import 'package:kairos/src/pages/focus_page.dart';
import 'package:kairos/src/pages/timeline_page.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.deepPurple,
      child: Column(
        children: [
          const DrawerHeader(
            child: Text('Profile details'),
          ),
          const SizedBox(height: 30),
          ListTile(
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FocusPage()),
              );
            },
          ),
          const ListTile(
            // grey out the option
            title: Text('Stats', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title:
                const Text('Timeline', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimelinePage()),
              );
            },
          ),
          const ListTile(
            // grey out the option
            title: Text('Leaderboard', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            // grey out the option
            title: Text('Tags', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            // grey out the option
            title: Text('Block Apps', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            // grey out the option
            title: Text('Settings', style: TextStyle(color: Colors.grey)),
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
