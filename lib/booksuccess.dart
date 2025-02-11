import 'package:dupepro/booknow.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class success extends StatefulWidget {
  const success({super.key});

  @override
  State<success> createState() => _successState();
}


class _successState extends State<success> {
  @override
  void initState() {
    super.initState();
    // Add a post-frame callback to delay the navigation to the next screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BookNow()),
        );
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.white, Colors.purple]),
            ),
            child: Center(
              child: Lottie.asset('asset/Animation - 1738836659721.json'),
              // Ensure the path is correct
            ),
          ),
          Text('Booking succsessful')
        ],
      ),
    );
  }
}
