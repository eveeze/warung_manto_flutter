// lib/pages/intro_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF093C25), // Dark green background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60), // Space from top
            Column(
              children: [
                Image.asset(
                  'public/hero.png', // Top icon
                  height: 150,
                ),
                const SizedBox(height: 24),
                Text(
                  'Kelola stok dan transaksi sembako dengan mudah dalam satu aplikasi!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 37,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B9B5E), // Button color
                    minimumSize: const Size(200, 60), // Full width button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to the login screen (home_screen)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text(
                    'Mulai Kelola',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Image.asset(
                  'public/sembakoku.png', // Bottom image
                  height: 380,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
