import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';

import '../models/location.dart';

class LocationsProvider extends ChangeNotifier {
  // ignore: prefer_final_fields
  List<Location> _locations = [];
  // ignore: prefer_final_fields
  Map<String, Color> _typesToColors = {
    'עיר': Colors.purple,
    'מיחזור': Colors.green,
    'בדיקה': Colors.blue,
  };

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
                      latLng: LatLng(document['latlng']['latitude'],
                          document['latlng']['longitude']),
                      address: document['address'],
                      type: document['type'],
                      color: !_typesToColors.keys.contains(document['type'])
                          ? _typesToColors[document['type']] = Colors.black
                          : _typesToColors[document['type']]!,
                      description: document['description'],
                    ),
                  ),
                }
            });
    notifyListeners();
  }

  Future<String> addLocation(
      LatLng latLng, String address, String type, String description) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('locations').add({
        'latlng': {'latitude': latLng.latitude, 'longitude': latLng.longitude},
        'address': address,
        'type': type,
        'description': description,
      });
      if (!_typesToColors.keys.contains(type)) {
        _typesToColors[type] = Colors.black;
      }
      _locations.add(
        Location(
          id: doc.id,
          latLng: latLng,
          address: address,
          type: type,
          color: _typesToColors[type]!,
          description: description,
        ),
      );
      notifyListeners();
      return 'done';
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
      return error.message.toString();
    }
  }

  void cleanDataOnExit() {
    _locations = [];
    notifyListeners();
  }

  List<Location> get locations => [..._locations];
}
