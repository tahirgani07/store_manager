import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final firebaseAuth = FirebaseAuth.instance;
  Future<bool> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await firebaseAuth.signInWithCredential(credential);
      return Future.value(true);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  Future<bool> signOut() {
    try {
      firebaseAuth.signOut();
      return Future.value(true);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }
}
