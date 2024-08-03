import 'package:flutter/material.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/pages/focus_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => GlobalStates(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FocusPage(),
    );
  }
}
