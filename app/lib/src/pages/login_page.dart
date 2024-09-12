import 'package:flutter/material.dart';
import 'package:kairos/src/global_states.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) =>
            Scaffold(backgroundColor: Colors.deepPurple, body: login()));
  }

  Widget login() {
    return Center(
      child: ElevatedButton(
          onPressed: handleGoogleSignIn,
          child: const Text("Sign in with Google")),
    );
  }

  Future handleGoogleSignIn() async {
    Navigator.pushNamed(context, '/focus');
  }
}
