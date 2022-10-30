import 'package:flutter/material.dart';

import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import 'package:provider/provider.dart';

import '../screens/place_info_screen.dart';

import '../models/location.dart';

import '../providers/locations_provider.dart';

class PlaceInfoPopup extends StatelessWidget {
  final String placeId;
  final PopupController infoController;

  const PlaceInfoPopup({
    super.key,
    required this.placeId,
    required this.infoController,
  });

  @override
  Widget build(BuildContext context) {
    final Location location =
        Provider.of<LocationsProvider>(context, listen: false)
            .findLocationById(placeId);
    return SizedBox(
      child: Card(
        child: ListTile(
          leading: IconButton(
            icon:
                const Icon(Icons.open_in_new, textDirection: TextDirection.rtl),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => PlaceInfoScreen(placeId: placeId)),
              ),
            ),
          ),
          title: Text(location.address),
          trailing: IconButton(
            onPressed: () => infoController.hideAllPopups(),
            icon: const Icon(Icons.close),
          ),
        ),
      ),
    );
  }
}
