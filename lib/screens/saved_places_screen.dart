import 'package:ecomap/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';

import '../models/location.dart';

import '../providers/auth_provider.dart';
import '../providers/locations_provider.dart';

import '../screens/place_info_screen.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  List<Widget> generatePlaces(
      AuthProvider userProvider, List<Location> allPlaces) {
    List<Widget> toReturn = [];
    List<String> toRemove = [];
    var data = userProvider.appUserData!;
    for (var id in data.savedPlaces) {
      final tryToFind = allPlaces.firstWhere(
        (element) => element.id == id,
        orElse: () => Location(
            id: '',
            name: '',
            latLng: LatLng(0, 0),
            address: '',
            type: '',
            color: Colors.transparent,
            description: '',
            imagebytes: ''),
      );
      if (tryToFind.id != '') {
        Location l = allPlaces.firstWhere((element) => element.id == id);
        toReturn.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              //shape: const StadiumBorder(),
              elevation: 5,
              //color: Color.fromARGB(255, 74, 133, 127),
              child: ListTile(
                tileColor: const Color.fromARGB(255, 176, 179, 137),
                title: Text(l.name),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: ((context) => PlaceInfoScreen(placeId: l.id)),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        toRemove.add(id);
      }
    }
    for (var id in toRemove) {
      userProvider.removeNonExistingPlace(id);
    }
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AuthProvider>(context, listen: false);
    final allPlaces =
        Provider.of<LocationsProvider>(context, listen: false).locations;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('המקומות ששמרתי'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [...generatePlaces(userProvider, allPlaces)],
          ),
        ),
      ),
    );
  }
}
