import 'package:flutter/material.dart';

import '../models/location.dart';

import 'package:provider/provider.dart';

import '../providers/locations_provider.dart';

class PlaceInfoScreen extends StatelessWidget {
  final String placeId;
  const PlaceInfoScreen({
    super.key,
    required this.placeId,
  });

  @override
  Widget build(BuildContext context) {
    final Location location =
        Provider.of<LocationsProvider>(context, listen: false)
            .findLocationById(placeId);
    final im = location.getImFromBase64();
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
      ),
      body: location.imagebytes == ""
          ? const Text('no image')
          : Center(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 2,
                  child: im),
            ),
    );
  }
}
