import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/location.dart';

class LocationsProvider extends ChangeNotifier {
  List<Location> _locations = [];

  Future<void> fetchLocations() async {
    await FirebaseFirestore.instance
        .collection('locations')
        .get()
        .then((data) => {
              for (var document in data.docs)
                {
                  _locations.add(
                    Location(
                      id: document.id,
                      latitude: document['latitude'],
                      longtitude: document['longtitude'],
                      adress: document['adress'],
                      type: document['type'],
                      color: Color(document['color']),
                      description: document['description'],
                    ),
                  ),
                }
            });
    notifyListeners();
  }

  List<Location> get locations => _locations;
}
