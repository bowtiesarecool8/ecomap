import 'package:flutter/material.dart';

import '../models/location.dart';

import 'package:provider/provider.dart';

import '../providers/locations_provider.dart';

class PlaceInfoScreen extends StatelessWidget {
  final String placeId;
  const PlaceInfoScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    final Location location =
        Provider.of<LocationsProvider>(context, listen: false)
            .findLocationById(placeId);
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     onPressed: () => Navigator.pop(context),
        //     icon: const Icon(Icons.close),
        //   ),
        // ],
        title: Text(location.address),
      ),
    );
  }
}
