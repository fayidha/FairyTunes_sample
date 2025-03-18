import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/History.dart';
import 'package:dupepro/cart.dart';
import 'package:dupepro/chatlist.dart';
import 'package:dupepro/home.dart';
import 'package:dupepro/seller_dash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _selectedIndex = 0;
  bool _isSeller = false;

  @override
  void initState() {
    super.initState();
    _checkIfSeller();
  }

  Future<void> _checkIfSeller() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _isSeller = userDoc.data()?['isSeller'] ?? false;
        });
      }
    }
  }

  List<Widget> get _pages {
    List<Widget> pages = [
      HomePage(),
      History(),
      CartPage(),
      ChatListScreen(),
      ProfilePage(),
    ];
    if (_isSeller) {
      pages.add(SellerDashboard());
    }
    return pages;
  }

  List<BottomNavigationBarItem> get _bottomNavItems {
    List<BottomNavigationBarItem> items = [
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
    ];
    if (_isSeller) {
      items.add(BottomNavigationBarItem(
          icon: Icon(Icons.store, color: Color(0xFF380230)),
          label: 'Dashboard'));
    }
    return items;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF380230),
        unselectedItemColor: Colors.white10,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: _bottomNavItems,
      ),
    );
  }
}
