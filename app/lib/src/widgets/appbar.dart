import 'package:flutter/material.dart';
import 'package:kairos/src/widgets/menu_button.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.deepPurple,
      leading: const MenuButton(),
      title: _focusModeHandler(),
      actions: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
          child: const Row(
            children: [
              Icon(Icons.sports_score_rounded),
              SizedBox(width: 5),
              Text(
                '1000',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _focusModeHandler() {
    return IconButton(
      onPressed: () {},
      icon: Icon(
        Icons.timer_rounded,
        color: Colors.black,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
