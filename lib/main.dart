import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:trumpet/database/db.dart';
import 'package:trumpet/landing_page.dart';
import 'package:trumpet/localization.dart';
import 'package:trumpet/tabs/groups/groups_page.dart';

import 'firebase_options.dart';
import 'tabs/events_page.dart';

import 'database/provider.dart' as provider;

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    localization.init(
      mapLocales: [
        const MapLocale('en', en_US),
      ],
      initLanguageCode: 'en',
    );
    localization.onTranslatedLanguage = _onTranslatedLanguage;
    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
      title: 'Trumpet',
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

  final _pages = [
    EventsPage(key: GlobalKey()),
    EventsPage(key: GlobalKey()),
    GroupsPage(key: GlobalKey()),
    EventsPage(key: GlobalKey()),
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

    _authStateChangesSubscription = FirebaseAuth.instance.authStateChanges().listen((loggedInUser) async {
      if (loggedInUser == null) {
        setState(() {
          loading = false;
          loggedIn = false;
        });
      } else {
        setState(() {
          loading = true;
          loggedIn = true;
        });

        provider.loggedInUser = await TUser.getOrCreate(loggedInUser);

        setState(() => loading = false);
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
            resizeToAvoidBottomInset: false,
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.timeline),
                  label: AppLocale.eventsPage_Title.getString(context),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_month),
                  label: AppLocale.calendarPage_Title.getString(context),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.groups),
                  label: AppLocale.groupsPage_Title.getString(context),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings),
                  label: AppLocale.settingsPage_Title.getString(context),
                ),
              ],
            ),
          )
        : const LandingPage();
  }
}
