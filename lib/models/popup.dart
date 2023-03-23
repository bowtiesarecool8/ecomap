import 'dart:convert';

import 'package:flutter/material.dart';

class AppPopUp {
  String id;
  String title;
  String content;
  String imageBytes;

  AppPopUp({
    required this.id,
    required this.title,
    required this.content,
    required this.imageBytes,
  });

  Image? getImFromBase64() {
    if (imageBytes == '') {
      return null;
    } else {
      final imageAsBytes = base64Decode(imageBytes);
      return Image.memory(imageAsBytes);
    }
  }
}
