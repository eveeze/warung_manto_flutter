// lib/pages/cash_screen.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minggu_4/pages/success_screen.dart';

class CashScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalCost;
  final String paymentType;
  final String token;
  final ValueChanged<void> onPaymentComplete;

  const CashScreen({
    super.key,
    required this.items,
    required this.totalCost,
    required this.paymentType,
    required this.token,
    required this.onPaymentComplete,
  });

  @override
  _CashScreenState createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  double amountPaid = 0.0;
  double change = 0.0;
  bool _isProcessing = false;
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final TextEditingController _amountController = TextEditingController();

  void calculateChange() {
    setState(() {
      change = amountPaid - widget.totalCost;
    });
  }

  Future<void> completePayment() async {
    // Validasi pembayaran
    if (amountPaid < widget.totalCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah pembayaran kurang',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set state processing
    setState(() {
      _isProcessing = true;
    });

    try {
      final transactionData = {
        'items': widget.items
            .map((item) => {
                  'productId': item['productId'],
                  'quantity': item['quantity'],
                })
            .toList(),
        'paymentType': widget.paymentType,
        'amountPaid': amountPaid,
        'totalCost': widget.totalCost,
      };

      final response = await http.post(
        Uri.parse('http://103.127.138.32/api/transaction/purchase'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(transactionData),
      );

      // Set state selesai processing
      setState(() {
        _isProcessing = false;
      });

      if (response.statusCode == 201) {
        // Panggil callback payment complete
        widget.onPaymentComplete(null);

        // Navigate ke SuccessScreen dengan token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              token: widget.token,
              items: widget.items,
              totalCost: widget.totalCost,
            ),
          ),
        );
      } else {
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaksi gagal: ${response.body}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Set state selesai processing
      setState(() {
        _isProcessing = false;
      });

      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Pembayaran Cash',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF093C25),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pesanan',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF093C25)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return ListTile(
                    title: Text(
                      item['productName'],
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      'Jumlah: ${item['quantity']}',
                      style: GoogleFonts.poppins(),
                    ),
                    trailing: Text(
                      'Harga: ${formatCurrency.format(item['price'])}',
                      style: GoogleFonts.poppins(),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Text(
              'Total Biaya: ${formatCurrency.format(widget.totalCost)}',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF093C25)),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Dibayar',
                labelStyle: GoogleFonts.poppins(),
              ),
              onChanged: (value) {
                setState(() {
                  amountPaid = double.tryParse(value) ?? 0.0;
                  calculateChange();
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Kembalian: ${formatCurrency.format(change)}',
              style: GoogleFonts.poppins(color: const Color(0xFF093C25)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : completePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B9B5E),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Konfirmasi Pembayaran',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
