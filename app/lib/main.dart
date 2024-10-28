import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kairos/firebase_options.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/pages/auth_page.dart';
import 'package:kairos/src/pages/focus_page.dart';
import 'package:kairos/src/pages/settings_page.dart';
import 'package:kairos/src/pages/timeline_page.dart';
import 'package:kairos/src/theme/default_theme.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
      create: (context) => GlobalStates(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => const AuthPage(),
        "/focus": (context) => const FocusPage(),
        "/timeline": (context) => const TimelinePage(),
        "/settings": (context) => const SettingsPage()
      },
      theme: defaultTheme,
    );
  }
}
