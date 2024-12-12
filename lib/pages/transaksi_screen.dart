// lib/pages/transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:minggu_4/pages/cash_screen.dart';
import 'package:minggu_4/pages/credit_screen.dart';
import 'package:minggu_4/pages/qris_screen.dart';

class TransaksiScreen extends StatefulWidget {
  final String token;
  final Map<String, int> cart;
  final ValueChanged<Map<String, int>> onCartUpdate;

  const TransaksiScreen({
    super.key,
    required this.token,
    required this.cart,
    required this.onCartUpdate,
  });

  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  Map<String, int> updatedCart = {};
  Map<String, dynamic> productDetails = {};
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    updatedCart = Map.from(widget.cart);
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final ids = updatedCart.keys.join(',');
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/products?ids=$ids'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Koneksi timeout');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List products = responseBody['products'];

        setState(() {
          for (var product in products) {
            productDetails[product['_id']] = product;
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat detail produk');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat detail produk: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void adjustQuantity(String productId, int delta) {
    setState(() {
      updatedCart[productId] = (updatedCart[productId] ?? 0) + delta;
      if (updatedCart[productId]! <= 0) {
        updatedCart.remove(productId);
      }
    });
    widget.onCartUpdate(updatedCart);
  }

  Future<void> proceedToPayment(String paymentType) async {
    // Validasi keranjang tidak kosong
    if (updatedCart.isEmpty) {
      _showErrorSnackBar('Keranjang masih kosong');
      return;
    }

    // Persiapkan data item
    final items = updatedCart.entries.map((entry) {
      final product = productDetails[entry.key];
      return {
        'productId': entry.key,
        'productName': product?['name'] ?? 'Produk Tidak Dikenal',
        'quantity': entry.value,
        'price': (product?['salePrice'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();

    // Hitung total biaya
    final totalCost = items.fold<double>(
      0,
      (sum, item) =>
          sum + (item['price'] as double) * (item['quantity'] as int),
    );

    try {
      switch (paymentType) {
        case 'qris':
          await _handleQRISPayment(items, totalCost);
          break;
        case 'cash':
          _navigateToCashScreen(items, totalCost, paymentType);
          break;
        case 'credit':
          _navigateToCreditScreen(items, totalCost, paymentType);
          break;
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memproses pembayaran: $e');
    }
  }

  Future<void> _handleQRISPayment(
      List<Map<String, dynamic>> items, double totalCost) async {
    final response = await http.post(
      Uri.parse('http://103.127.138.32/api/transaction/purchase'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'items': items
            .map((item) =>
                {'productId': item['productId'], 'quantity': item['quantity']})
            .toList(),
        'paymentType': 'qris',
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final qrisUrl = responseData['qrisUrl'];
      final orderId = responseData['orderId'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRISScreen(
            items: items,
            totalCost: totalCost,
            qrisUrl: qrisUrl,
            orderId: orderId,
            token: widget.token,
            onPaymentComplete: (_) {
              _resetCart();
            },
          ),
        ),
      );
    } else {
      _showErrorSnackBar('Transaksi QRIS gagal: ${response.body}');
    }
  }

  void _navigateToCashScreen(
      List<Map<String, dynamic>> items, double totalCost, String paymentType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashScreen(
          items: items,
          totalCost: totalCost,
          paymentType: paymentType,
          token: widget.token,
          onPaymentComplete: (_) {
            _resetCart();
          },
        ),
      ),
    );
  }

  void _navigateToCreditScreen(
      List<Map<String, dynamic>> items, double totalCost, String paymentType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreditScreen(
          items: items,
          totalCost: totalCost,
          paymentType: paymentType,
          token: widget.token,
          onPaymentComplete: (_) {
            _resetCart();
          },
        ),
      ),
    );
  }

  void _resetCart() {
    setState(() {
      updatedCart.clear();
      widget.onCartUpdate(updatedCart);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF093C25),
          title: Text(
            'Memuat Keranjang',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B9B5E)),
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat detail produk...',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
      );
    }
    final totalCost = updatedCart.entries.fold<double>(
      0,
      (sum, entry) {
        final product = productDetails[entry.key];
        return sum + ((product?['salePrice'] ?? 0.0) * entry.value);
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF093C25),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Keranjang Belanja',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: updatedCart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 100,
                          color: const Color(0xFF093C25).withOpacity(0.5),
                        ),
                        Text(
                          'Keranjang Anda Kosong',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF093C25),
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: updatedCart.keys.length,
                    itemBuilder: (context, index) {
                      final productId = updatedCart.keys.elementAt(index);
                      final quantity = updatedCart[productId] ?? 0;
                      final product = productDetails[productId];
                      final productName = product != null
                          ? product['name']
                          : 'Product ID: $productId';
                      final productPrice =
                          product != null ? product['salePrice'] : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              productName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${formatCurrency.format(productPrice)}\nJumlah: $quantity',
                              style: GoogleFonts.poppins(),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(0xFF093C25),
                                  ),
                                  onPressed: () =>
                                      adjustQuantity(productId, -1),
                                ),
                                Text(
                                  '$quantity',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFF1B9B5E),
                                  ),
                                  onPressed: () => adjustQuantity(productId, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Total dan Metode Pembayaran
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Total Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatCurrency.format(totalCost),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B9B5E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Pilihan Metode Pembayaran
                Text(
                  'Pilih Metode Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPaymentMethodButton(
                      icon: Icons.money,
                      label: 'Cash',
                      onPressed: () => proceedToPayment("cash"),
                      color: const Color(0xFF093C25),
                    ),
                    _buildPaymentMethodButton(
                      icon: Icons.credit_card,
                      label: 'Credit',
                      onPressed: () => proceedToPayment("credit"),
                      color: const Color(0xFF1B9B5E),
                    ),
                    _buildPaymentMethodButton(
                      icon: Icons.qr_code,
                      label: 'QRIS',
                      onPressed: () => proceedToPayment("qris"),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    final isCartEmpty = updatedCart.isEmpty;
    return ElevatedButton(
      onPressed: isCartEmpty
          ? null // Nonaktifkan tombol jika keranjang kosong
          : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCartEmpty
            ? Colors.grey.shade300 // Warna abu-abu saat dinonaktifkan
            : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isCartEmpty
                  ? Colors
                      .grey.shade500 // Warna ikon abu-abu saat dinonaktifkan
                  : Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isCartEmpty
                  ? Colors
                      .grey.shade500 // Warna teks abu-abu saat dinonaktifkan
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
