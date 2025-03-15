import 'package:flutter/material.dart';

class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final String bookingId;
  final Function(String) onCancel;

  BookingDetailsPage({
    required this.bookingData,
    required this.bookingId,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard('Group Name', bookingData['groupName']),
                  _buildDetailCard('Event Location', bookingData['eventLocation']),
                  _buildDetailCard('Event Type', bookingData['eventType']),
                  _buildDetailCard('Program Date', bookingData['programDate']),
                  _buildDetailCard('Program Time', bookingData['programTime']),
                  _buildDetailCard(
                    'Status',
                    bookingData['status'],
                    color: _getStatusColor(bookingData['status']),
                  ),
                  _buildDetailCard('User Name', bookingData['userName']),
                  _buildDetailCard('User Email', bookingData['userEmail']),
                  _buildDetailCard('Phone', bookingData['phone']),
                  _buildDetailCard('Timestamp', bookingData['timestamp'].toDate().toString()),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Cancel Booking Button (Only if status is "Booked")
          if (bookingData['status'] == 'Booked')
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => onCancel(bookingId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel Booking',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, {Color? color}) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to set the color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Booked':
        return Colors.green;
      case 'Confirmed':
        return Colors.blue;
      case 'Cancelled':
      case 'Denied':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
