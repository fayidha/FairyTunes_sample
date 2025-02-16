import 'package:dupepro/Acc_rej_band.dart';
import 'package:flutter/material.dart';
import 'package:dupepro/view/artist_profile.dart';

class ArtistTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Artists'),
          bottom: const TabBar(
            indicatorWeight: 4,
            indicatorColor: Color(0xFF380230), // Indicator color
            tabs: [
              Tab(
                icon: Icon(Icons.music_note_rounded, color: Color(0xFF380230)),
                text: 'Artist Profile',
              ),
              Tab(
                icon: Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF380230)),
                text: 'Requests',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ArtistProfile(), // Artist Profile Page
            BandRequestsPage(), // Booking History Page
          ],
        ),
      ),
    );
  }
}
