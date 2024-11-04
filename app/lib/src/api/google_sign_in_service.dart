import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kairos/src/shared_prefs.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(clientId: _initializeClientId(), scopes: ['email']);

  static String _initializeClientId() {
    if (kIsWeb) {
      // static const baseUrl = String.fromEnvironment('SERVER_URL',
      //     defaultValue: 'http://localhost:3333');
      return const String.fromEnvironment('GOOGLE_CLIENT_ID_WEB');
    } else if (Platform.isIOS) {
      return const String.fromEnvironment('GOOGLE_CLIENT_ID_IOS');
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment('GOOGLE_CLIENT_ID_ANDROID');
    } else if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return const String.fromEnvironment('GOOGLE_CLIENT_ID_DESKTOP');
    } else {
      return '';
    }
  }

  GoogleSignIn get googleSignIn {
    return _googleSignIn;
  }

  final FirebaseAuth _firebaseInstance = FirebaseAuth.instance;
  User? getCurrentUser() {
    return _firebaseInstance.currentUser;
  }

  Future<UserCredential> googleLogin() async {
    final GoogleSignInAccount? gUser = await googleSignIn.signIn();
    // If user cancels sign in, return
    if (gUser == null) {
      throw Exception("User cancelled");
    }
    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    try {
      return await _firebaseInstance.signInWithCredential(credential);
    } catch (e) {
      throw Exception("Error signing in");
    }
  }

  logout() async {
    _firebaseInstance.signOut();
    SharedPrefs().setLoggedIn(false);
  }
}
