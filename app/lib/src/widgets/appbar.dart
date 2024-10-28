import 'package:flutter/material.dart';
import 'package:kairos/src/widgets/menu_button.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: const MenuButton(),
      title: _focusModeHandler(context),
      actions: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          // padding: const EdgeInsets.all(10),
          // child: const Row(
          //   children: [
          //     Icon(Icons.sports_score_rounded),
          //     SizedBox(width: 5),
          //     Text(
          //       '1000',
          //       style: TextStyle(
          //         fontSize: 15,
          //         color: Colors.black,
          //       ),
          //     )
          //   ],
          // ),
        ),
      ],
    );
  }

  Widget _focusModeHandler(context) {
    // show this icon only when the current path is /focus
    if (ModalRoute.of(context)!.settings.name == '/focus') {
      return IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.timer_rounded,
          // color: Theme.of(context).colorScheme.secondary,
          color: Colors.grey[400],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
