import 'package:flutter/services.dart';

class Location {
  final String id;
  final double latitude;
  final double longtitude;
  final String adress;
  final String type;
  final Color color;
  final String description;

  Location({
    required this.id,
    required this.latitude,
    required this.longtitude,
    required this.adress,
    required this.type,
    required this.color,
    required this.description,
  });
}
