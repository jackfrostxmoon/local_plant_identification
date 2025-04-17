import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/widgets/custom_bottom_nav_bar.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
  }

  // Placeholder pages with proper error handling
  final List<Widget> _widgetOptions = <Widget>[
    const SafeArea(
      child: Center(
        child: Text('Home Page Content', style: TextStyle(fontSize: 16)),
      ),
    ),
    const SafeArea(
      child: Center(
        child: Text('Search Page Content', style: TextStyle(fontSize: 16)),
      ),
    ),
    const SafeArea(
      child: Center(
        child: Text('Favourite Page Content', style: TextStyle(fontSize: 16)),
      ),
    ),
    const SafeArea(
      child: Center(
        child: Text('User Page Content', style: TextStyle(fontSize: 16)),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    if (mounted && index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onFabTapped() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera action!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          onFabTap: _onFabTapped,
        ),
      ),
    );
  }
}
