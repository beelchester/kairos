import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final FirebaseAuth _firebaseInstance = FirebaseAuth.instance;
  User? getCurrentUser() {
    return _firebaseInstance.currentUser;
  }

  Future<UserCredential> googleLogin() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    // If user cancels sign in, return
    if (gUser == null) {
      throw Exception("User cancelled");
    }
    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return _firebaseInstance.signInWithCredential(credential);
  }

  logout() async {
    _firebaseInstance.signOut();
  }
}
