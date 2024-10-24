import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatefulWidget {
  final String token; // Accept the JWT token

  const MainScreen({
    super.key,
    required this.token, // Token passed from the login screen
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch the user's data on initialization
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/auth/user-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}', // Pass the token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Pengguna';
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        userName = 'Pengguna';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xFFFFC107); // Define yellow color

    return Scaffold(
      backgroundColor: Colors.white, // Light background for better contrast
      appBar: AppBar(
        backgroundColor: primaryYellow,
        title: const Text('Warung Mbah Manto',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Profile Picture and Greeting in a Row layout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar image with shadow
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                            './public/gigachad.jpg', // Replace with your profile image path
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(width: 16),
                        // Text greeting with yellow accent
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hallo, ${userName ?? 'Pengguna'}', // Display fetched user name
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryYellow,
                                ),
                              ),
                              const Text(
                                'Selamat Pagi.',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Large food image with rounded corners and shadow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          './public/foods.png', // Replace with your food image path
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List of food with images and prices
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daftar Makanan:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryYellow,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            ListTile(
                              leading: Image(
                                image: AssetImage(
                                    './public/burger.jpeg'), // Replace with food icon
                                width: 40,
                                height: 40,
                              ),
                              title: Text(
                                'Burger',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('Rp23.000'),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: primaryYellow),
                            ),
                            ListTile(
                              leading: Image(
                                image: AssetImage(
                                    './public/bakso.png'), // Replace with food icon
                                width: 40,
                                height: 40,
                              ),
                              title: Text(
                                'Bakso',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('Rp15.000'),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: primaryYellow),
                            ),
                            ListTile(
                              leading: Image(
                                image: AssetImage(
                                    './public/mie.png'), // Replace with food icon
                                width: 40,
                                height: 40,
                              ),
                              title: Text(
                                'Mie Ayam',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('Rp17.000'),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: primaryYellow),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
