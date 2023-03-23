import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './screens/home_screen.dart';

import './providers/auth_provider.dart';
import './providers/locations_provider.dart';
import './providers/all_users_provider.dart';
import './providers/feedback_provider.dart';
import './providers/information_provider.dart';
import './providers/popups_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PopupsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AllUsers(),
        ),
        ChangeNotifierProvider(
          create: (context) => FeedbackProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CityInformationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasData) {
                return const HomeScreen();
              } else {
                return const AuthScreen();
              }
            },
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
