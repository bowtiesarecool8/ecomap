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

import './place_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  LatLng pos = LatLng(31.92933, 34.79868);
  bool isFirstBuild = true;
  bool isLoading = false;
  bool isEditing = false;

  PopupController infoController = PopupController();

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
    List<Marker> locationMarkers = locationsProvider.locations.map(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('שלום!'),
        actions: [
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
              child: Column(
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
                              popupSnap: PopupSnap.mapLeft,
                              popupBuilder: (ctx, p1) {
                                // Navigator.push(
                                //   ctx,
                                //   MaterialPageRoute(
                                //     builder: (context) => PlaceInfoScreen(
                                //       placeId: p1.key.toString().substring(
                                //             3,
                                //             p1.key.toString().length - 3,
                                //           ),
                                //     ),
                                //   ),
                                // );
                                return PlaceInfoPopup(
                                  placeId: p1.key.toString().substring(
                                        3,
                                        p1.key.toString().length - 3,
                                      ),
                                  infoController: infoController,
                                );
                                // SizedBox(
                                //   height: MediaQuery.of(context).size.height,
                                //   width: MediaQuery.of(context).size.width / 2,
                                //   child: Card(
                                //       color: Colors.white,
                                //       child: Padding(
                                //         padding: const EdgeInsets.all(8.0),
                                //         child: Text(p1.key.toString()),
                                //       )),
                                // );
                              },
                              popupState: PopupState(),
                            ),
                            maxClusterRadius: 120,
                            size: const Size(40, 40),
                            fitBoundsOptions: const FitBoundsOptions(
                              padding: EdgeInsets.all(50),
                            ),
                            markers: locationMarkers,
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
