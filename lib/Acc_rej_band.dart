import 'package:flutter/material.dart';

class BandRequestsPage extends StatefulWidget {
  @override
  _BandRequestsPageState createState() => _BandRequestsPageState();
}

class _BandRequestsPageState extends State<BandRequestsPage> {
  final List<Map<String, dynamic>> bandRequests = [
    {'name': 'The Rockers', 'genre': 'Rock', 'image': 'https://via.placeholder.com/150', 'accepted': false},
    {'name': 'Jazz Vibes', 'genre': 'Jazz', 'image': 'https://via.placeholder.com/150', 'accepted': false},
    {'name': 'Electro Beats', 'genre': 'Electronic', 'image': 'https://via.placeholder.com/150', 'accepted': false},
    {'name': 'Soul Harmony', 'genre': 'Soul', 'image': 'https://via.placeholder.com/150', 'accepted': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        itemCount: bandRequests.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(bandRequests[index]['image']),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bandRequests[index]['name'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        bandRequests[index]['genre'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                bandRequests[index]['accepted']
                    ? ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Accepted', style: TextStyle(color: Colors.black54)),
                )
                    : Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          bandRequests[index]['accepted'] = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF380230),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          bandRequests.removeAt(index);
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Color(0xFF380230)),
                      ),
                      child: Text('Reject', style: TextStyle(color: Color(0xFF380230))),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
