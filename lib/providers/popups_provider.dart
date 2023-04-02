import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/popup.dart';

class PopupsProvider extends ChangeNotifier {
  List<AppPopUp> _popups = [];
  bool _isViewed = false;

  List<AppPopUp> get popups {
    return [..._popups];
  }

  bool get isViewed {
    return _isViewed;
  }

  Future<void> fetchData() async {
    try {
      _popups = [];
      await FirebaseFirestore.instance.collection('popups').get().then((data) {
        for (var document in data.docs) {
          _popups.add(
            AppPopUp(
              id: document.id,
              title: document['title'],
              content: document['content'],
              imageBytes: document['imageBytes'],
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

  Future<String> addPopup(
      String title, String content, String imageBytes) async {
    try {
      final newDoc = await FirebaseFirestore.instance.collection('popups').add({
        'title': title,
        'content': content,
        'imageBytes': imageBytes,
      });
      _popups.add(
        AppPopUp(
          id: newDoc.id,
          title: title,
          content: content,
          imageBytes: imageBytes,
        ),
      );
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      return 'התרחשה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  Future<String> editPopup(
      String id, String title, String content, String imageBytes) async {
    AppPopUp forEdit = _popups.firstWhere((element) => element.id == id);
    try {
      await FirebaseFirestore.instance.collection('popups').doc(id).update({
        'title': title,
        'content': content,
        'imageBytes': imageBytes,
      });
      forEdit.title = title;
      forEdit.content = content;
      forEdit.imageBytes = imageBytes;
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      return 'התרחשה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  Future<String> deletePopup(String id) async {
    int index = _popups.indexWhere((element) => element.id == id);
    final forDelete = _popups.removeAt(index);
    try {
      await FirebaseFirestore.instance.collection('popups').doc(id).delete();
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      _popups.add(forDelete);
      notifyListeners();
      return 'התרחשה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  void userViewedPopups() {
    _isViewed = true;
    notifyListeners();
  }

  void noDupes() {
    _popups = _popups.toSet().toList();
    notifyListeners();
  }
}
