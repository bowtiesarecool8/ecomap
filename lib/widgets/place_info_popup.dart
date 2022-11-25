import 'package:flutter/material.dart';

import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import 'package:provider/provider.dart';

import '../screens/place_info_screen.dart';

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
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: const Text('האם למחוק את המקום מהמפה?'),
                        content: isLoading
                            ? const CircularProgressIndicator()
                            : null,
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('לא'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              final String response =
                                  await Provider.of<LocationsProvider>(context,
                                          listen: false)
                                      .deleteLocation(location.id);
                              setState(() {
                                isLoading = false;
                              });
                              if (response != 'done') {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response),
                                  ),
                                );
                              }
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('כן'),
                          ),
                        ],
                        actionsAlignment: MainAxisAlignment.spaceAround,
                      ),
                    ),
                  );
                },
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
