import 'package:flutter/material.dart';

import '../screens/saved_places_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

class NormalAppDrawer extends StatelessWidget {
  const NormalAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5,
            color: Theme.of(context).colorScheme.primary,
            child: Center(
              child: Text(
                'שלום, ${FirebaseAuth.instance.currentUser!.displayName}',
                style:
                    const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('מועדפים'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const SavedPlacesScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
