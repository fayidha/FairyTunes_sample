import 'package:dupepro/bottomBar.dart';
import 'package:flutter/material.dart';

class BandSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF380230), size: 100), // Purple tick
            SizedBox(height: 20),
            Text(
              'Band Created Successfully!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:() {
               Navigator.push(context, MaterialPageRoute(builder: (context) => BottomBarScreen(),));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF380230),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
