import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';

class Location {
  final String id;
  final String name;
  final LatLng latLng;
  final String address;
  final String type;
  final Color color;
  final String description;

  Location({
    required this.id,
    required this.name,
    required this.latLng,
    required this.address,
    required this.type,
    required this.color,
    required this.description,
  });
}
