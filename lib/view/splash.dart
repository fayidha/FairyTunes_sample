/*
import 'package:dupepro/bottomBar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _splashState();
}

class _splashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomBarScreen(),
            ));
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple],
          ),
        ),
        child: Center(
          child: Lottie.asset('asset/animation1.json'),
        ),
      ),
    );
  }
}
*/




import 'package:dupepro/bottomBar.dart';
import 'package:dupepro/controller/session.dart';
import 'package:dupepro/view/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _splashState();
}

class _splashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Add a post-frame callback to delay the navigation to the next screen
   /* WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginForm()),
        );
      });
    });*/
    _checkSession();
  }


  // Check session and navigate accordingly
  Future<void> _checkSession() async {
    final sessionData = await Session.getSession();
    final bool isLoggedIn = sessionData['uid'] != null;

    // Delay for splash animation
    await Future.delayed(const Duration(seconds: 3));

    // Navigate to Home if logged in, else Login
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomBarScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginForm()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Color(0xFF380230)]),
        ),
        child: Center(
          child: Lottie.asset('asset/animation1.json'),
        ),
      ),
    );
  }
}
