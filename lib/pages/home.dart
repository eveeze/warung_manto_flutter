import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:minggu_4/components/bottom_navigation_bar.dart';
import 'dart:convert';
import 'package:minggu_4/pages/main_screen.dart';
import 'package:minggu_4/pages/user_screen.dart';
import 'package:minggu_4/pages/crud_transaction_screen.dart';

class HomesScreen extends StatefulWidget {
  final String token;

  const HomesScreen({
    super.key,
    required this.token,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomesScreen> {
  int _currentIndex = 0;
  String userName = '';
  double todayProfit = 0.0;
  List<dynamic> recentProducts = [];
  List<dynamic> recentTransactions = [];
  bool isLoading = true;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomesScreen(token: widget.token),
      MainScreen(token: widget.token),
      CrudTransactionScreen(token: widget.token),
      UserScreen(token: widget.token)
    ];

    fetchUserData();
    fetchTodayProfit();
    fetchRecentProducts();
    fetchRecentTransactions();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/auth/user-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['name'] ?? 'User '; // Default to 'User ' if null
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomesScreen(token: widget.token)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(token: widget.token)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CrudTransactionScreen(token: widget.token)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserScreen(token: widget.token)),
        );
        break;
    }
  }

  Future<void> fetchTodayProfit() async {
    try {
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/transaction/profit-today'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          todayProfit = data['totalProfit']?.toDouble() ?? 0.0;
        });
      } else {
        throw Exception('Failed to load today\'s profit');
      }
    } catch (error) {
      print('Error fetching today\'s profit: $error');
    }
  }

  Future<void> fetchRecentProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/products?limit=5'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recentProducts = data['products'] ?? [];
        });
      } else {
        throw Exception('Failed to load recent products');
      }
    } catch (error) {
      print('Error fetching recent products: $error');
    }
  }

  Future<void> fetchRecentTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/transaction?limit=5'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recentTransactions = data['transactions'] ?? [];
          isLoading = false; // Stop loading after fetching data
        });
      } else {
        throw Exception('Failed to load recent transactions');
      }
    } catch (error) {
      print('Error fetching recent transactions: $error');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF093C25),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section with Gradient
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF093C25), Color(0xFF1B5E40)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userName,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Profit Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.trending_up,
                                      color: Color(0xFF093C25),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Profit Hari Ini',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF093C25),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Rp${todayProfit.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF093C25),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons Section
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Produk',
                              Icons.inventory_2_outlined,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainScreen(
                                      token: widget.token,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              'Transaksi',
                              Icons.receipt_long_outlined,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CrudTransactionScreen(
                                              token: widget.token)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Recent Products Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Produk Terbaru',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF093C25),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                    token: widget.token,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF093C25),
                            ),
                            label: Text(
                              'Lihat Semua',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF093C25),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: recentProducts.length,
                        itemBuilder: (context, index) {
                          final product = recentProducts[index];
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    product['imageUrl'] ??
                                        'https://via.placeholder.com/150',
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? 'No Name',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp${product['salePrice']?.toString() ?? '0'}',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF093C25),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Recent Transactions Section
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaksi Terakhir',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF093C25),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = recentTransactions[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF093C25)
                                        .withOpacity(0.1),
                                    child: const Icon(
                                      Icons.receipt,
                                      color: Color(0xFF093C25),
                                    ),
                                  ),
                                  title: Text(
                                    transaction['_id'] ?? 'Transaksi',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Rp${transaction['totalCost']?.toStringAsFixed(2) ?? '0'}',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF093C25),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        transaction['status'] ?? '',
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      transaction['paymentStatus'] ?? 'Pending',
                                      style: GoogleFonts.poppins(
                                        color: _getStatusColor(
                                          transaction['status'] ?? '',
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF093C25),
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
