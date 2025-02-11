import 'package:carousel_slider/carousel_slider.dart';
import 'package:dupepro/booknow.dart';
import 'package:flutter/material.dart';

class TroupDetail extends StatelessWidget {
  final int index;

  TroupDetail({required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Troupe ${index + 1}", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel for images
            CarouselSlider(
              items: [
                'asset/210379377.png',
                'asset/img1.jpg',
                'asset/music.jpg'
              ]
                  .map((item) => Image.asset(item, fit: BoxFit.cover, width: double.infinity))
                  .toList(),
              options: CarouselOptions(
                height: 150,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
            ),

            // Name of the troupe leader
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Troupe Leader: Troupe ${index + 1}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // Phone number
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey),
                SizedBox(width: 9),
                Text('98765${index + 676767}'),
              ],
            ),

            // Email
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey),
                SizedBox(width: 9),
                Text('troupe${index + 1}@mail.com'),
              ],
            ),

            // Experience
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 9),
                  Text('Experience: ${index + 2} years'),
                ],
              ),
            ),

            // More About Us
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'More About Us: Troupe ${index + 1} is a professional music group offering various performances for events. They specialize in live music shows and offer customized performance packages.',
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Book Now Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => BookNow(),));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF380230),
                  foregroundColor: Color(0xFFFFFFFF),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Book Now',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
