import 'package:flutter/material.dart';
import 'account_screen.dart';
import 'new_meeting_screen.dart';
import 'statistics_screen.dart';
import 'auth_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GameStatisticsApp());
}

class GameStatisticsApp extends StatelessWidget {
  const GameStatisticsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Statistics App',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selecterIndex = 0;

  final List<Widget> _widgedOptions = <Widget>[
    StatisticsScreen(),
    NewMeetingScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selecterIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Statistics'),
      ),
      body: Center(
        child: _widgedOptions.elementAt(_selecterIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad_rounded),
            label: 'Meeting'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Account'
          ),
        ],
        currentIndex: _selecterIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

