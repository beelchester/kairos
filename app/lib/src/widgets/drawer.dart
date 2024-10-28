import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      child: Column(
        children: [
          const DrawerHeader(
            child: Text('Profile details'),
          ),
          const SizedBox(height: 30),
          ListTile(
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/focus');
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
              Navigator.pushNamed(context, '/timeline');
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
