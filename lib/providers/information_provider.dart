// ignore_for_file: prefer_final_fields

import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/information.dart';

class CityInformationProvider extends ChangeNotifier {
  String _garbageCollection = '';
  List<CityNotificationObject> _cityInfo = [];

  String get garbageCollection {
    return _garbageCollection;
  }

  List<CityNotificationObject> get cityInfo {
    return [..._cityInfo];
  }

  Future<void> fetchData() async {
    try {
      List<CityNotificationObject> cityNotes = [];
      final garbage = await FirebaseFirestore.instance
          .collection('information')
          .doc('garbageCollection')
          .get();
      final notif = await FirebaseFirestore.instance
          .collection('information')
          .doc('CityNotifications')
          .collection('allNotifications')
          .get();
      for (var doc in notif.docs) {
        Timestamp date = doc['date'];
        cityNotes.add(CityNotificationObject(
            id: doc.id,
            date: DateTime.parse(date.toDate().toString()),
            content: doc['content']));
      }
      _garbageCollection = garbage['content'];
      _cityInfo = cityNotes;
      notifyListeners();
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  Future<String> updateNotification(String id, String content) async {
    final n = _cityInfo.firstWhere((element) => element.id == id);
    final oldContent = n.content;
    try {
      n.content = content;
      await FirebaseFirestore.instance
          .collection('information')
          .doc('CityNotifications')
          .collection('allNotifications')
          .doc(id)
          .update(
        {'content': content},
      );
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      n.content = oldContent;
      notifyListeners();
      return 'התרחשה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  Future<String> deleteNotification(String id) async {
    final forDelete = _cityInfo.firstWhere((element) => element.id == id);
    try {
      _cityInfo.remove(forDelete);
      await FirebaseFirestore.instance
          .collection('information')
          .doc('CityNotifications')
          .collection('allNotifications')
          .doc(id)
          .delete();
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      _cityInfo.add(forDelete);
      notifyListeners();
      return 'התרחשה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  Future<String> addNotification(DateTime date, String content) async {
    try {
      Timestamp t = Timestamp.fromDate(date);
      final doc = await FirebaseFirestore.instance
          .collection('information')
          .doc('CityNotifications')
          .collection('allNotifications')
          .add({
        'date': t,
        'content': content,
      });
      _cityInfo.add(
        CityNotificationObject(
          id: doc.id,
          date: date,
          content: content,
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

  Future<String> updateGarbage(String content) async {
    final oldContent = _garbageCollection;
    try {
      _garbageCollection = content;
      await FirebaseFirestore.instance
          .collection('information')
          .doc('garbageCollection')
          .update({'content': _garbageCollection});
      notifyListeners();
      return 'ok';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      _garbageCollection = oldContent;
      notifyListeners();
      return 'התרחשה שגיאה, נסו שנית מאוחר יותר';
    }
  }

  void noDupes() {
    _cityInfo = _cityInfo.toSet().toList();
    notifyListeners();
  }
}
