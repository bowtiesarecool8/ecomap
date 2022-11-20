import 'package:ecomap/models/location.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import '../providers/auth_provider.dart';

import '../providers/locations_provider.dart';

import '../widgets/add_place.dart';
import '../widgets/place_info_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  List<Location> _locations = [];
  List<Marker> _locationMarkers = [];
  LatLng pos = LatLng(31.92933, 34.79868);
  bool isFirstBuild = true;
  bool isLoading = false;
  bool isEditing = false;
  bool _showFilters = false;

  Map<String, bool> typeChecks = {
    'מרכז מיחזור': true,
    'ערך מורשת וטבע': true,
    'קומפוסטר שיתופי': true,
    'גינה קהילתית': true,
    'ספסל מסירה': true,
    'מקרר חברתי': true,
    'השאלת כלים': true,
    'עצי פרי': true,
    'תיבת קינון': true,
    'גינת כלבים': true,
    'עסק סביבתי': true,
    'מוקד קהילתי': true,
    'אתר בסיכון': true,
  };

  PopupController infoController = PopupController();

  List<Widget> generateFilters(LocationsProvider prov) {
    List<Widget> filterOptions = [
      const Text(
        'סנן סוגי אתרים:',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      )
    ];
    Map<String, Color> typesToColors = prov.types;
    for (String type in typesToColors.keys) {
      filterOptions.add(
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          checkColor: const Color(0xffeaeaea),
          activeColor: typesToColors[type],
          title: Text(
            type,
          ),
          value: typeChecks[type],
          onChanged: (value) {
            setState(() {
              typeChecks[type] = value!;
            });
          },
        ),
      );
    }
    filterOptions.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              List<Location> filtered = [];
              final places = prov.locations;
              for (var pl in places) {
                if (typeChecks[pl.type] == true) {
                  filtered.add(pl);
                }
              }
              setState(() {
                _locations = filtered;
                _showFilters = false;
              });
            },
            child: const Text('סנן!'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              setState(() {
                for (var k in typeChecks.keys) {
                  typeChecks[k] = true;
                }
                _locations = prov.locations;
                _showFilters = false;
              });
            },
            child: const Text('איפוס סינון'),
          ),
        ],
      ),
    );
    return filterOptions;
  }

  List<Marker> generateMarkers(List<Location> locations) {
    List<Marker> returnList = locations.map(
      (element) {
        return Marker(
          key: ValueKey(element.id),
          point: element.latLng,
          builder: (context) => Icon(
            Icons.location_pin,
            size: 35,
            color: element.color,
          ),
        );
      },
    ).toList();
    return returnList;
  }

  @override
  Future<void> didChangeDependencies() async {
    if (isFirstBuild) {
      setState(() {
        isLoading = true;
      });
      await Provider.of<LocationsProvider>(context, listen: false)
          .fetchLocations()
          .then((value) {
        setState(() {
          _locations =
              Provider.of<LocationsProvider>(context, listen: false).locations;
          isLoading = false;
          isFirstBuild = false;
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AuthProvider>(context);
    final locationsProvider = Provider.of<LocationsProvider>(context);
    _locationMarkers = generateMarkers(_locations);
    return Scaffold(
      appBar: AppBar(
        title: const Text('שלום!'),
        actions: [
          IconButton(
            onPressed: () {
              if (_showFilters) {
                for (var type in typeChecks.keys) {
                  typeChecks[type] = true;
                }
              }
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: _showFilters
                ? const Icon(Icons.close)
                : const Icon(Icons.filter_list_outlined),
          ),
          IconButton(
            onPressed: () {
              userProvider.logout();
              locationsProvider.cleanDataOnExit();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: _showFilters
                  ? SingleChildScrollView(
                      child: Column(
                        children: generateFilters(locationsProvider),
                      ),
                    )
                  : Column(
                      children: [
                        Flexible(
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(31.92933, 34.79868),
                              zoom: 15,
                              onTap: (tapPosition, point) async {
                                if (isEditing) {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => AddPlace(
                                      latLng: point,
                                    ),
                                  );
                                  setState(() {
                                    isEditing = false;
                                  });
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerClusterLayerWidget(
                                options: MarkerClusterLayerOptions(
                                  popupOptions: PopupOptions(
                                    popupController: infoController,
                                    popupSnap: PopupSnap.markerTop,
                                    popupBuilder: (ctx, p1) {
                                      return PlaceInfoPopup(
                                        placeId: p1.key.toString().substring(
                                              3,
                                              p1.key.toString().length - 3,
                                            ),
                                        infoController: infoController,
                                      );
                                    },
                                    popupState: PopupState(),
                                  ),
                                  maxClusterRadius: 120,
                                  size: const Size(40, 40),
                                  fitBoundsOptions: const FitBoundsOptions(
                                    padding: EdgeInsets.all(50),
                                  ),
                                  markers: _locationMarkers,
                                  builder: (context, markers) {
                                    return Center(
                                      child: FloatingActionButton(
                                        onPressed: () {},
                                        child: const Text(''),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
      floatingActionButton: CircleAvatar(
        child: IconButton(
          icon: Icon(isEditing ? Icons.close : Icons.edit),
          onPressed: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
        ),
      ),
    );
  }
}
