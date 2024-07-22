import 'package:flutter/material.dart';
import 'package:kairos/src/utils.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showNotAvailable(context);
      },
      icon: const Icon(Icons.menu),
    );
  }
}
