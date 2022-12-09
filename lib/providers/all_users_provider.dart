import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class AllUsers extends ChangeNotifier {
  List<AppUserData> _allUsers = [];

  Future<void> fetchData() async {
    try {
      await FirebaseFirestore.instance.collection('users').get().then((data) {
        for (var document in data.docs) {
          _allUsers.add(
            AppUserData(
              uid: document.id,
              email: document['email'],
              savedPlaces: document['saved'],
              isAdmin: document['admin'],
            ),
          );
        }
      });
      notifyListeners();
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  List<AppUserData> get allUsers {
    return [..._allUsers];
  }

  List<AppUserData> allAdmins() {
    return [..._allUsers.where((element) => element.isAdmin)];
  }

  Future<String> addAdmin(String uid) async {
    try {
      _allUsers.firstWhere((element) => element.uid == uid).isAdmin = true;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'admin': true});
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      _allUsers.firstWhere((element) => element.uid == uid).isAdmin = false;
      notifyListeners();
      return error.message.toString();
    }
  }

  Future<String> removeAdmin(String uid) async {
    try {
      _allUsers.firstWhere((element) => element.uid == uid).isAdmin = false;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'admin': false});
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      _allUsers.firstWhere((element) => element.uid == uid).isAdmin = true;
      notifyListeners();
      return error.message.toString();
    }
  }
}
