import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with Email and Password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Verify if the user is authenticated or not
  /// Returns the user if he is authenticated, null otherwise
  Future<User?> checkUserAuthentication() async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        // L'utilisateur est authentifié, vous pouvez effectuer des actions liées à l'authentification ici.
        // Par exemple, vous pouvez obtenir les détails de l'utilisateur avec user.displayName, user.email, etc.
        return user;
      } else {
        // L'utilisateur n'est pas authentifié.
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
