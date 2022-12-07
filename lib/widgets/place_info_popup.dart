import 'package:flutter/material.dart';

import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import 'package:provider/provider.dart';

import '../screens/place_info_screen.dart';
import '../screens/delete_location_screen.dart';

import '../widgets/edit_place.dart';

import '../providers/locations_provider.dart';
import '../providers/auth_provider.dart';

class PlaceInfoPopup extends StatefulWidget {
  // List<Location> locations;
  final String placeId;
  final PopupController infoController;

  const PlaceInfoPopup({
    super.key,
    //required this.locations,
    required this.placeId,
    required this.infoController,
  });

  @override
  State<PlaceInfoPopup> createState() => _PlaceInfoPopupState();
}

class _PlaceInfoPopupState extends State<PlaceInfoPopup> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final location = Provider.of<LocationsProvider>(context, listen: false)
        .findLocationById(widget.placeId);
    final isAdmin =
        Provider.of<AuthProvider>(context, listen: false).appUserData!.isAdmin;
    return SizedBox(
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new,
                  textDirection: TextDirection.rtl),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: ((context) =>
                      PlaceInfoScreen(placeId: widget.placeId)),
                ),
              ),
            ),
            Text(location.name),
            if (isAdmin)
              IconButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => EditPlace(
                      oldLocation:
                          Provider.of<LocationsProvider>(context, listen: false)
                              .locations
                              .firstWhere(
                                  (element) => element.id == widget.placeId),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            if (isAdmin)
              IconButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: ((context) => DeleteLocationScreen(
                        placeId: widget.placeId, location: location)),
                  ),
                ),
                icon: const Icon(Icons.delete),
              ),
            IconButton(
              onPressed: () => widget.infoController.hideAllPopups(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
