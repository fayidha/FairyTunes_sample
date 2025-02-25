import 'package:flutter/material.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  final List<Map<String, dynamic>> bookings = const [
    {
      "bookingId": "BK001",
      "date": "Feb 20, 2025",
      "service": "Hotel Stay",
      "location": "Hilton, New York",
      "price": 250.00,
      "status": "Completed"
    },
    {
      "bookingId": "BK002",
      "date": "Mar 10, 2025",
      "service": "Flight Ticket",
      "location": "Los Angeles to Chicago",
      "price": 320.50,
      "status": "Upcoming"
    },
    {
      "bookingId": "BK003",
      "date": "Jan 05, 2025",
      "service": "Car Rental",
      "location": "Miami, Florida",
      "price": 150.75,
      "status": "Cancelled"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: Colors.deepPurple,
      ),
      body: bookings.isEmpty
          ? const Center(child: Text("No past bookings found"))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Icon(
                  Icons.book_online,
                  color: Colors.deepPurple,
                ),
              ),
              title: Text(
                booking["service"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${booking["date"]}"),
                  Text("Location: ${booking["location"]}"),
                  Text("Price: \$${booking["price"].toStringAsFixed(2)}"),
                ],
              ),
              trailing: Text(
                booking["status"],
                style: TextStyle(
                  color: _getStatusColor(booking["status"]),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Navigate to booking details page if needed
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Upcoming":
        return Colors.orange;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
