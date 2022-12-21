import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/locations_provider.dart';

import '../providers/auth_provider.dart';

import './add_feedback_screen.dart';

class PlaceInfoScreen extends StatefulWidget {
  final String placeId;
  const PlaceInfoScreen({
    super.key,
    required this.placeId,
  });

  @override
  State<PlaceInfoScreen> createState() => _PlaceInfoScreenState();
}

class _PlaceInfoScreenState extends State<PlaceInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final location = Provider.of<LocationsProvider>(context, listen: false)
        .findLocationById(widget.placeId);
    final userProviderInstance =
        Provider.of<AuthProvider>(context, listen: false);
    final im = location.getImFromBase64();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            location.name,
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final response =
                    await userProviderInstance.updateSaved(location.id);
                if (response != 'ok') {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response),
                    ),
                  );
                }
                setState(() {});
              },
              icon: userProviderInstance.appUserData!.isSaved(location.id)
                  ? const Icon(Icons.bookmark)
                  : const Icon(Icons.bookmark_border),
            ),
          ],
        ),
        body: SingleChildScrollView(
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
                title: Text(location.address),
              ),
              ListTile(
                leading:
                    CircleAvatar(radius: 18, backgroundColor: location.color),
                title: Text(location.type),
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
                title: Text(location.description),
              ),
              if (location.imagebytes != "")
                Center(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                      child: im),
                ),
            ],
          ),
        ),
        floatingActionButton: OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: BorderSide(
                  width: 1, color: Theme.of(context).colorScheme.primary)),
          onPressed: (() {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => AddFeedbackScreen(
                      placeId: widget.placeId,
                    )),
              ),
            );
          }),
          child: const Text('יש בעיה? ספרו לנו!'),
        ),
      ),
    );
  }
}
