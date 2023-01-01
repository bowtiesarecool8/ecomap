import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  AppUserData? _appUserData;

  GoogleSignInAccount get user {
    return _user!;
  }

  AppUserData? get appUserData {
    return _appUserData;
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

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final email = FirebaseAuth.instance.currentUser!.email!;
    final username = FirebaseAuth.instance.currentUser!.displayName!;
    final photoURL = FirebaseAuth.instance.currentUser!.photoURL!;
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'saved': [],
          'admin': false,
          'email': email,
          'username': username,
          'profile': photoURL,
        });
        _appUserData = AppUserData(
          uid: uid,
          email: email,
          username: username,
          profileImageURL: photoURL,
          savedPlaces: [],
          isAdmin: false,
        );
      } else {
        final savedPlaces = userDoc['saved'];
        final isAdmin = userDoc['admin'];
        _appUserData = AppUserData(
          uid: uid,
          email: email,
          username: username,
          profileImageURL: photoURL,
          savedPlaces: savedPlaces,
          isAdmin: isAdmin,
        );
      }
      notifyListeners();
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  Future<void> logout() async {
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
    _appUserData = null;
    notifyListeners();
  }

  Future<String> updateSaved(String placeId) async {
    try {
      if (_appUserData!.isSaved(placeId)) {
        _appUserData!.unsavePlace(placeId);
      } else {
        _appUserData!.savePlace(placeId);
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_appUserData!.uid)
          .update({'saved': _appUserData!.savedPlaces});
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      if (_appUserData!.isSaved(placeId)) {
        _appUserData!.unsavePlace(placeId);
      } else {
        _appUserData!.savePlace(placeId);
      }
      notifyListeners();
      return 'אירעה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  Future<void> removeNonExistingPlace(String locationId) async {
    _appUserData!.savedPlaces.remove(locationId);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_appUserData!.uid)
          .update({'saved': _appUserData!.savedPlaces});
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }
}
