import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../screens/saved_places_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/info_screen.dart';

class AdminAppDrawer extends StatelessWidget {
  const AdminAppDrawer({super.key});

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
          const Padding(
            padding: EdgeInsets.all(10),
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
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('הגדרות מנהל'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const SettingsScreen()),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('מידע עירוני'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const InfoScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
