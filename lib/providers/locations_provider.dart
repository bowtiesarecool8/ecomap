import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';

import '../models/location.dart';

class LocationsProvider extends ChangeNotifier {
  // ignore: prefer_final_fields
  List<Location> _locations = [];
  // ignore: prefer_final_fields
  static const Map<String, Color> _typesToColors = {
    'מרכז מיחזור': Color.fromARGB(255, 23, 129, 26),
    'ערך מורשת וטבע': Color.fromARGB(255, 96, 5, 112),
    'קומפוסטר שיתופי': Color.fromARGB(255, 75, 21, 2),
    'גינה קהילתית': Colors.red,
    'ספסל מסירה': Color.fromARGB(255, 13, 91, 155),
    'מקרר חברתי': Colors.cyan,
    'השאלת כלים': Color.fromARGB(255, 228, 169, 6),
    'עצי פרי': Color.fromARGB(255, 252, 93, 1),
    'תיבת קינון': Colors.lightGreen,
    'גינת כלבים': Color.fromARGB(255, 88, 69, 58),
    'עסק סביבתי': Color.fromARGB(255, 121, 131, 37),
    'מוקד קהילתי': Color.fromARGB(255, 196, 67, 110),
    'אתר בסיכון': Color.fromARGB(255, 54, 87, 104),
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
                      name: document['name'],
                      latLng: LatLng(document['latlng']['latitude'],
                          document['latlng']['longitude']),
                      address: document['address'],
                      type: document['type'],
                      color: _typesToColors[document['type']]!,
                      description: document['description'],
                      imagebytes: document['image bytes'],
                    ),
                  ),
                }
            });
    notifyListeners();
  }

  Future<String> addLocation(String name, LatLng latLng, String address,
      String type, String description, String imageBytes) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('locations').add({
        'name': name,
        'latlng': {'latitude': latLng.latitude, 'longitude': latLng.longitude},
        'address': address,
        'type': type,
        'description': description,
        'image bytes': imageBytes,
      });
      _locations.add(
        Location(
          id: doc.id,
          name: name,
          latLng: latLng,
          address: address,
          type: type,
          color: _typesToColors[type]!,
          description: description,
          imagebytes: imageBytes,
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

  Location findLocationById(String id) {
    return _locations.firstWhere((element) => element.id == id);
  }

  void cleanDataOnExit() {
    _locations = [];
    notifyListeners();
  }

  List<Location> get locations => [..._locations];

  Map<String, Color> get types => {..._typesToColors};
}
