import 'package:dupepro/booknow.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Success extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? location;

  const Success({required this.groupId, required this.groupName, this.location, super.key});

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  @override
  void initState() {
    super.initState();
    // Delay navigation to the booking page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookNow(
              groupId: widget.groupId,
              groupName: widget.groupName,
              location: widget.location,
            ),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white, Colors.purple]),
              ),
              child: Center(
                child: Lottie.asset('asset/Animation - 1738836659721.json'), // Ensure this file exists
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Booking Successful!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
