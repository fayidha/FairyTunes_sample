import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FancyPromoText extends StatelessWidget {
  const FancyPromoText({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.deepPurpleAccent,
      highlightColor: Colors.pinkAccent,
      child: Text(
        "🎶 Book your favorite music bands and tracks today for an unforgettable experience!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
