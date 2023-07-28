import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trumpet/landing_page.dart';

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
    final app = await Firebase.initializeApp();
    var loggedInUser = FirebaseAuth.instance.currentUser;
    if (loggedInUser == null) {
      loading = false;
      loggedIn = false;
    } else {
      setState(() {
        loading = false;
        loggedIn = true;
      });
    }
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
