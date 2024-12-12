// lib/pages/success_screen.dart
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:minggu_4/pages/main_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String token;
  final List<Map<String, dynamic>> items;
  final double totalCost;

  const SuccessScreen(
      {Key? key,
      required this.token,
      required this.items,
      required this.totalCost})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Biaya: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(totalCost)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Kembali ke MainScreen dengan token
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(token: token),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Kembali ke Halaman Utama'),
            ),
          ],
        ),
      ),
    );
  }
}
