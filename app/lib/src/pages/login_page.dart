import 'package:flutter/material.dart';
import 'package:kairos/src/api/google_sign_in_service.dart';
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
        builder: (context, globalStates, child) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: login()));
  }

  Widget login() {
    return Center(
      child: ElevatedButton(
          onPressed: handleGoogleSignIn,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          child: const Text("Sign in with Google",
              style: TextStyle(color: Colors.black))),
    );
  }

  Future handleGoogleSignIn() async {
    try {
      await GoogleSignInService().googleLogin();
    } catch (e) {
      print(e);
    }
  }
}
