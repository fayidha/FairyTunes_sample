import 'package:dupepro/bookinghistory.dart';
import 'package:dupepro/orderhistory.dart';
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            indicatorWeight: 4,
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart), text: 'Cart'),
              Tab(icon: Icon(Icons.book_online), text: 'Booking History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderHistoryPage(),
           BookingHistoryPage(),
          ],
        ),
      ),
    );
  }
}
