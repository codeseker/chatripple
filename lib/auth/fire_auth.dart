import 'package:firebase_auth/firebase_auth.dart';

class FireAuth {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static Future registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    User? user;

    try {
      // user credentials like email and password
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // If the account creation is successful, the user variable is assigned the User object from the userCredential.
      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        return "The account already exists for that email.";
      }
    } catch (e) {
      return "Something error occured.";
    }
    return null;
  }

  static Future loginUsingEmailPassword(
      {required String email, required String password}) async {
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        return "Wrong password provided.";
      }
    }
    return null;
  }
}
