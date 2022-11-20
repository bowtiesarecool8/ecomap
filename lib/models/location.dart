import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  final String imagebytes;

  Location({
    required this.id,
    required this.name,
    required this.latLng,
    required this.address,
    required this.type,
    required this.color,
    required this.description,
    required this.imagebytes,
  });

  Future<Image?> getImFromBase64(String base64String) async {
    if (base64String == '') {
      return null;
    } else {
      Image? im;
      final imageAsBytes = base64Decode(base64String);
      try {
        im = (await decodeImageFromList(imageAsBytes)) as Image?;
        return im;
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
        return null;
      }
    }
  }
}
