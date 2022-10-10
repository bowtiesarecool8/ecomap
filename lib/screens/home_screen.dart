import 'package:ecomap/screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import '../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('hi'),
        actions: [
          IconButton(
            onPressed: () {
              userProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AuthScreen(),
                ),
              );
            },
            icon: const Text('sign out'),
          ),
        ],
      ),
      body: Center(
          child: CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(user.photoURL!),
      )),
    );
  }
}
