import 'package:flutter/material.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  final List<Map<String, String>> bookingHistory = [
    {
      'event': 'SHOWNEW',
      'date': '2025-02-10',
      'status': 'Completed'
    },
    {
      'event': 'Guitar SHOW',
      'date': '2025-02-12',
      'status': 'Pending'
    },
    {
      'event': 'Violin Recital',
      'date': '2025-02-08',
      'status': 'Cancelled'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking History'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: bookingHistory.length,
        itemBuilder: (context, index) {
          final booking = bookingHistory[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            child: ListTile(
              leading: Icon(
                booking['status'] == 'Completed'
                    ? Icons.check_circle
                    : booking['status'] == 'Pending'
                    ? Icons.hourglass_empty
                    : Icons.cancel,
                color: booking['status'] == 'Completed'
                    ? Colors.green
                    : booking['status'] == 'Pending'
                    ? Colors.orange
                    : Colors.red,
              ),
              title: Text(booking['event'] ?? 'Unknown Event',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Date: ${booking['date']}'),
              trailing: Text(
                booking['status'] ?? '',
                style: TextStyle(
                  color: booking['status'] == 'Completed'
                      ? Colors.green
                      : booking['status'] == 'Pending'
                      ? Colors.orange
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

