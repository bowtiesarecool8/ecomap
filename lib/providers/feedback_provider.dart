import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/feedback.dart';

class FeedbackProvider extends ChangeNotifier {
  List<UserFeedback> _feedbacks = [];

  Future<void> fetchData(bool isAdmin) async {
    if (isAdmin) {
      _feedbacks = [];
      try {
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .get()
            .then((data) {
          for (var document in data.docs) {
            Timestamp time = document['uploadTime'];
            _feedbacks.add(
              UserFeedback(
                id: document.id,
                writerId: document['writer'],
                uploadTime: DateTime.parse(time.toDate().toString()),
                locationID: document['location'],
                content: document['content'],
                isDone: document['done'],
              ),
            );
          }
        });
        _feedbacks.sort(
          (a, b) => a.uploadTime.compareTo(b.uploadTime),
        );
        _feedbacks = _feedbacks.reversed.toList();
        notifyListeners();
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error.message);
        }
      }
    }
  }

  Future<String> publishFeedback(
      String uid, String locationId, String content) async {
    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'writer': uid,
        'uploadTime': Timestamp.fromDate(DateTime.now()),
        'location': locationId,
        'content': content,
        'done': false,
      });
      return 'done';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      return 'אירעה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  Future<String> changeStatus(String id, bool isDone) async {
    UserFeedback feedback =
        _feedbacks.firstWhere((element) => element.id == id);

    try {
      feedback.isDone = isDone;
      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(id)
          .update({'done': isDone});
      notifyListeners();
      return 'done';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      feedback.isDone = !isDone;
      return 'אירעה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  Future<void> removeFeedbacksOnDeletedPlace(UserFeedback f) async {
    _feedbacks.remove(f);
    try {
      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(f.id)
          .delete();
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  void cleanDataOnExit() {
    _feedbacks = [];
    notifyListeners();
  }

  void noDupes() {
    _feedbacks = _feedbacks.toSet().toList();
    notifyListeners();
  }

  List<UserFeedback> get allFeedbacks {
    return [..._feedbacks];
  }
}
