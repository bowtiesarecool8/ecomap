import 'package:flutter/material.dart';

import '../models/location.dart';

import '../providers/auth_provider.dart';

class PlaceInfoWidget extends StatefulWidget {
  final Location location;
  final AuthProvider userProviderInstance;
  final Image? im;

  const PlaceInfoWidget({
    super.key,
    required this.location,
    required this.userProviderInstance,
    required this.im,
  });

  @override
  State<PlaceInfoWidget> createState() => _PlaceInfoWidgetState();
}

class _PlaceInfoWidgetState extends State<PlaceInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: Stack(
              alignment: Alignment.center,
              children: const [
                CircleAvatar(
                  radius: 20,
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.place),
                ),
              ],
            ),
            title: Text(widget.location.address),
          ),
          ListTile(
            leading: CircleAvatar(
                radius: 18, backgroundColor: widget.location.color),
            title: Text(widget.location.type),
          ),
          ListTile(
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.info,
                size: 30,
              ),
            ),
            title: Text(widget.location.description),
          ),
          if (widget.location.imagebytes != "")
            Center(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height * 3 / 8,
                  child: widget.im),
            ),
        ],
      ),
    );
  }
}
