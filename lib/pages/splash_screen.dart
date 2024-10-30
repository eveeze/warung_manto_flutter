import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF093C25), // Dark green background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The logo part of the splash screen
            Container(
              width:
                  300, // Adjust the width and height to fit the logo perfectly
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'public/hero.png'), // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // The text under the logo
            const Text(
              'Warung Mbah Manto',
              style: TextStyle(
                fontSize: 30, // Adjust the font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
