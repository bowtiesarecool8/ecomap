import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

class UserProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;

  GoogleSignInAccount get user {
    return _user!;
  }

  Future<String?> login() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      return error.message;
    } on PlatformException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      return error.message;
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      return error.toString();
    }
    return null;
  }

  Future<void> logout() async {
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
