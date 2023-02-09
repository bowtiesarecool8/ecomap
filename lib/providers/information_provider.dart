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
}
