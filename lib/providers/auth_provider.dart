import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  String _uid = '';
  String _email = '';
  List<String> _savedPlaces = [];
  bool _isAdmin = false;

  GoogleSignInAccount get user {
    return _user!;
  }

  String get uid {
    return _uid;
  }

  String get email {
    return _email;
  }

  List<String> get savedPlaces {
    return [..._savedPlaces];
  }

  bool get isAdmin {
    return _isAdmin;
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
      _uid = FirebaseAuth.instance.currentUser!.uid;
      _email = FirebaseAuth.instance.currentUser!.email!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'saved': [],
          'admin': false,
          'email': _email,
        });
      } else {
        _savedPlaces = userDoc['saved'] as List<String>;
        _isAdmin = userDoc['admin'];
      }
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
    _uid = '';
    _email = '';
    _savedPlaces = [];
    _isAdmin = false;
    notifyListeners();
  }
}
