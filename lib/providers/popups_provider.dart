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

  void userViewedPopups() {
    _isViewed = true;
    notifyListeners();
  }
}
