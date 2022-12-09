import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../screens/home_screen.dart';

import '../providers/locations_provider.dart';

import '../models/location.dart';

import '../main.dart';

class DeleteLocationScreen extends StatefulWidget {
  final String placeId;
  final Location location;
  const DeleteLocationScreen({
    super.key,
    required this.placeId,
    required this.location,
  });

  @override
  State<DeleteLocationScreen> createState() => _DeleteLocationScreenState();
}

class _DeleteLocationScreenState extends State<DeleteLocationScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // final location = Provider.of<LocationsProvider>(context, listen: false)
    //     .findLocationById(widget.placeId);
    final im = widget.location.getImFromBase64();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: ((context) => const Directionality(
                        textDirection: TextDirection.rtl, child: HomeScreen())),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_sharp),
              ),
              Text(
                'האם למחוק את ${widget.location.name}?',
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (!isLoading)
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
              if (!isLoading)
                ListTile(
                  leading: CircleAvatar(
                      radius: 18, backgroundColor: widget.location.color),
                  title: Text(widget.location.type),
                ),
              if (!isLoading)
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
              if (!isLoading)
                if (widget.location.imagebytes != "")
                  Center(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 2,
                        child: im),
                  ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final String response = await Provider.of<LocationsProvider>(
                          context,
                          listen: false)
                      .deleteLocation(widget.location.id);
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
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('המיקום נמחק'),
                      ),
                    );
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Directionality(
                          textDirection: TextDirection.rtl, child: MyApp()),
                    ),
                  );
                },
                child: const Text('כן, אני רוצה למחוק את המקום הזה'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
