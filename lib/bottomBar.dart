import 'package:dupepro/History.dart';
import 'package:dupepro/cart.dart';
import 'package:dupepro/chatlist.dart';
import 'package:dupepro/home.dart';
import 'package:flutter/material.dart';

import 'profile.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    History(),
    CartPage(),
    Chatlist(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Show the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF380230),
        unselectedItemColor: Colors.white10,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Color(0xFF380230)), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history, color: Color(0xFF380230)),
              label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, color: Color(0xFF380230)),
              label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message, color: Color(0xFF380230)),
              label: 'Messages'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Color(0xFF380230)), label: 'You'),
        ],
        unselectedLabelStyle: TextStyle(color: Color(0xFF380230)),
        selectedLabelStyle: TextStyle(color: Color(0xFF380230)),
      ),
    );
  }
}