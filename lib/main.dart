import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trumpet/landing_page.dart';

import 'firebase_options.dart';
import 'tabs/events.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StreamSubscription _authStateChangesSubscription;

  var loading = false;
  var loggedIn = false;

  var _selectedIndex = 0;

  final _pages = const [
    EventsPage(),
    EventsPage(),
    EventsPage(),
    EventsPage(),
  ];

  @override
  void initState() {
    _initFirebase();
    super.initState();
  }

  void _initFirebase() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    var loggedInUser = FirebaseAuth.instance.currentUser;
    if (loggedInUser == null) {
      setState(() {
        loading = false;
        loggedIn = false;
      });
    } else {
      setState(() {
        loading = false;
        loggedIn = true;
      });
    }

    _authStateChangesSubscription = FirebaseAuth.instance.authStateChanges().listen((loggedInUser) {
      if (loggedInUser == null) {
        setState(() {
          loading = false;
          loggedIn = false;
        });
      } else {
        setState(() {
          loading = false;
          loggedIn = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _authStateChangesSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loggedIn || loading
        ? Scaffold(
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.timeline),
                  label: 'Events',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups),
                  label: 'Groups',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          )
        : const LandingPage();
  }
}
