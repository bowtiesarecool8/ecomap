import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

import '../providers/auth_provider.dart';

import '../providers/locations.dart';

import '../widgets/add_place.dart';

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
                        onTap: (tapPosition, point) {
                          showDialog(
                            context: context,
                            builder: (_) => AddPlace(
                              latLng: point,
                            ),
                          );
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: locationMarkers,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
