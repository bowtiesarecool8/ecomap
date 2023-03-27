// ignore_for_file: use_build_context_synchronously

import 'package:ecomap/models/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import 'package:geocoding/geocoding.dart' as geo_coding;

import '../providers/auth_provider.dart';
import '../providers/locations_provider.dart';
import '../providers/all_users_provider.dart';
import '../providers/feedback_provider.dart';
import '../providers/information_provider.dart';
import '../providers/popups_provider.dart';

import '../widgets/add_place.dart';
import '../widgets/place_info_popup.dart';
import '../widgets/admin_app_drawer.dart';
import '../widgets/normal_app_drawer.dart';

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
    filterOptions.add(
      SizedBox(
        height: (3 * MediaQuery.of(context).size.height) / 4,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 1,
          ),
          itemCount: typesToColors.keys.length,
          itemBuilder: ((context, index) {
            final typeKey = typesToColors.keys.toList()[index];
            return GridTile(
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                checkColor: const Color(0xffeaeaea),
                activeColor: typesToColors[typeKey],
                title: Text(
                  typeKey,
                ),
                value: typeChecks[typeKey],
                onChanged: (value) {
                  setState(() {
                    typeChecks[typeKey] = value!;
                  });
                },
              ),
            );
          }),
        ),
      ),
    );
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

  void showPopups(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: ((ctx) {
        int index = 0;
        final popups = Provider.of<PopupsProvider>(ctx, listen: false).popups;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(popups[index].title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(popups[index].content),
                if (popups[index].imageBytes != "")
                  popups[index].getImFromBase64()!,
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              IconButton(
                onPressed: index == 0
                    ? null
                    : () {
                        setState(() {
                          index = index + 1;
                        });
                      },
                icon: const Icon(Icons.arrow_back_ios_rounded),
              ),
              IconButton(
                onPressed: index >= popups.length - 1
                    ? null
                    : () {
                        setState(() {
                          index = index + 1;
                        });
                      },
                icon: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Future<void> didChangeDependencies() async {
    if (isFirstBuild) {
      setState(() {
        isLoading = true;
      });
      await Provider.of<AuthProvider>(context, listen: false)
          .fetchUserData()
          .then((_) async {
        await Provider.of<AllUsers>(context, listen: false)
            .fetchData()
            .then((_) async {
          await Provider.of<LocationsProvider>(context, listen: false)
              .fetchLocations()
              .then((_) async {
            await Provider.of<FeedbackProvider>(context, listen: false)
                .fetchData(Provider.of<AuthProvider>(context, listen: false)
                    .appUserData!
                    .isAdmin)
                .then((_) async {
              await Provider.of<CityInformationProvider>(context, listen: false)
                  .fetchData()
                  .then((_) async {
                await Provider.of<PopupsProvider>(context, listen: false)
                    .fetchData()
                    .then((_) {
                  _locations =
                      Provider.of<LocationsProvider>(context, listen: false)
                          .locations;
                  isFirstBuild = false;
                  setState(() {
                    isLoading = false;
                  });
                });
              });
            });
          });
        });
      });

      if (!Provider.of<PopupsProvider>(context, listen: false).isViewed) {
        Provider.of<PopupsProvider>(context, listen: false).userViewedPopups();
        showPopups(context);
      }
      super.didChangeDependencies();
    }
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
            onPressed: () => showPopups(context),
            icon: const Icon(
              Icons.info,
            ),
          ),
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
              setState(() {
                userProvider.logout();
                locationsProvider.cleanDataOnExit();
                Provider.of<FeedbackProvider>(context, listen: false)
                    .cleanDataOnExit();
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: isLoading
          ? null
          : userProvider.appUserData!.isAdmin
              ? const AdminAppDrawer()
              : const NormalAppDrawer(),
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
                              zoom: 15.5,
                              onTap: (tapPosition, point) async {
                                if (isEditing) {
                                  List<geo_coding.Placemark> address = [];
                                  try {
                                    address = await geo_coding
                                        .GeocodingPlatform.instance
                                        .placemarkFromCoordinates(
                                            point.latitude, point.longitude,
                                            localeIdentifier: 'he_il');
                                  } on PlatformException catch (error) {
                                    if (kDebugMode) {
                                      print(error.toString());
                                    }
                                  }
                                  // ignore: use_build_context_synchronously
                                  await showDialog(
                                    context: context,
                                    builder: (_) => AddPlace(
                                      latLng: point,
                                      autoAddress: address,
                                    ),
                                  );
                                  await locationsProvider.fetchLocations();
                                  setState(() {
                                    isEditing = false;
                                    _locations = Provider.of<LocationsProvider>(
                                            context,
                                            listen: false)
                                        .locations;
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
      floatingActionButton: isLoading
          ? null
          : !userProvider.appUserData!.isAdmin
              ? null
              : _showFilters
                  ? null
                  : CircleAvatar(
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
