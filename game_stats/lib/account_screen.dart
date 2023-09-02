import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_stats/auth_service.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  User? currentUser;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    getCurrentUser();

    _widgetOptions = <Widget>[
      SignupScreen(),
      SigninScreen(
        onSignIn: () {
          getCurrentUser();
        },
      ),
    ];
  }

  void getCurrentUser() async {
    currentUser = await _authService.getCurrentUser();
    setState(() {});
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dane konta'),
        ),
        body: const Center(
          // child: //TO DO -----------------> Account Details
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Wylogowanie użytkownika
            await _authService.signOut();
            getCurrentUser();
          },
          child: const Icon(Icons.logout),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dane konta'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupScreen(),
                    ),
                  );
                },
                child: const Text('Zarejestruj'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SigninScreen(
                        onSignIn: () {
                          getCurrentUser();
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Zaloguj'),
              ),
            ],
          ),
        ),
      );
    }
  }
}