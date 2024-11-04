import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kairos/src/api/api_service.dart';
import 'package:kairos/src/api/google_sign_in_service.dart';
import 'package:kairos/src/api/models/user.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/shared_prefs.dart';
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
    if (kIsWeb) {
      GoogleSignInService().googleSignIn.isSignedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: login(context)));
  }

  Widget login(BuildContext context) {
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
      var googleUser = await GoogleSignInService().googleLogin();
      var uid = googleUser.user?.uid;
      var email = googleUser.user?.email;
      var name = googleUser.user?.displayName;
      debugPrint("user is ${googleUser.user}");
      if (googleUser.user != null &&
          uid != null &&
          email != null &&
          name != null) {
        var user = User(userId: uid, email: email, name: name);
        await ApiService.addUser(user);
      }
    } catch (e) {
      if (e.toString().contains("User already exists")) {
        debugPrint("user already exists");
      } else {
        print(e);
        throw e;
      }
    }
    SharedPrefs().setLoggedIn(true);
    debugPrint("user added");
  }
}
