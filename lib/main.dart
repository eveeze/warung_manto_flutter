import 'package:flutter/material.dart';
import 'package:minggu_4/pages/main_screen.dart';
import 'package:minggu_4/pages/splash_screen.dart';
import 'package:minggu_4/pages/intro_screen.dart';
import 'package:minggu_4/pages/transaksi_screen.dart';
import 'package:minggu_4/pages/cash_screen.dart';
import 'package:minggu_4/pages/success_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Mbah Manto',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreenPage(), // Start with splash screen
      routes: {
        '/intro': (context) => const IntroScreen(),
        '/product': (context) => const MainScreen(token: 'token'),
        '/transaksi': (context) => TransaksiScreen(
              token: 'your_token', // Replace with actual token
              cart: const {}, // Replace with actual cart data
              onCartUpdate: (updatedCart) {},
            ),
        '/cash': (context) => CashScreen(
              items: const [], // Replace with actual items
              totalCost: 0.0, // Replace with actual total cost
              paymentType: 'cash', // Replace with the appropriate payment type
              token: 'your_token', // Replace with actual token
              onPaymentComplete: (_) {},
            ),
        '/success': (context) => const SuccessScreen(
              token: '',
              items: [],
              totalCost: 0.0,
            ),
      },
    );
  }
}

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to IntroScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/intro');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // Show the splash screen first
  }
}
