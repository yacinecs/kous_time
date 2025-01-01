import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kous_time/widgets/Favorite.dart';
import 'package:kous_time/widgets/google_maps.dart';
import 'package:kous_time/widgets/schedules.dart';
import 'package:kous_time/widgets/Settings.dart';
import 'package:kous_time/widgets/planner.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  
  runApp(const MyApp());
   // For layout issues
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kous Time',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.onlyShowSelected;

  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        bottomNavigationBar: NavigationBar(
          labelBehavior: labelBehavior,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Colors.blue,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.map),
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.next_plan),
              icon: Icon(Icons.next_plan_outlined),
              label: 'Planner',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.schedule),
              icon: Icon(Icons.schedule_outlined),
              label: 'Schedule',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.favorite_outlined),
              icon: Icon(Icons.favorite_border),
              label: 'Favorite',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
        body: <Widget>[
          GoogleMaps(),
          Planner(),
          Schedule(),
          Favorite(),
          SettingsPage()


        ][currentPageIndex]
    );
  }
  }




