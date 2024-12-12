import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF093C25),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Dapatkan ukuran layar
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Tentukan ukuran responsif
          double topImageHeight = screenHeight * 0.2;
          double titleFontSize = screenWidth < 600 ? 24 : 37;
          double buttonWidth = screenWidth * 0.7;
          double bottomImageHeight = screenHeight * 0.4;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          'public/hero.png',
                          height: topImageHeight,
                          width: screenWidth * 0.6,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Kelola stok dan transaksi sembako dengan mudah dalam satu aplikasi!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B9B5E),
                            minimumSize: Size(buttonWidth, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          },
                          child: Text(
                            'Mulai Kelola',
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Image.asset(
                          'public/sembakoku.png',
                          height: bottomImageHeight,
                          width: screenWidth,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
