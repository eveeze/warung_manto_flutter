import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:minggu_4/pages/success_screen.dart';

class QRISScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalCost;
  final String qrisUrl;
  final String orderId;
  final String token;
  final ValueChanged<void> onPaymentComplete;

  const QRISScreen({
    super.key,
    required this.items,
    required this.totalCost,
    required this.qrisUrl,
    required this.orderId,
    required this.token,
    required this.onPaymentComplete,
  });

  @override
  _QRISScreenState createState() => _QRISScreenState();
}

class _QRISScreenState extends State<QRISScreen> {
  bool _isChecking = false;
  bool _paymentCompleted = false;

  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  Future<void> checkPaymentStatus(BuildContext context) async {
    // Hindari pemeriksaan berulang jika pembayaran sudah selesai
    if (_paymentCompleted) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://103.127.138.32/api/transaction/qris-status/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      setState(() {
        _isChecking = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['transactionStatus'] == 'completed') {
          setState(() {
            _paymentCompleted = true;
          });

          // Panggil callback payment complete
          widget.onPaymentComplete(null);

          // Navigate ke SuccessScreen dengan parameter yang diperlukan
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
          // Tampilkan pesan jika pembayaran belum selesai
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pembayaran belum selesai. Silakan coba lagi.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Tangani kesalahan respons
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memeriksa status pembayaran. Silakan coba lagi.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
      });

      // Tangani kesalahan koneksi atau server
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
    // Print QR URL for simulation
    print("QR URL for simulation: ${widget.qrisUrl}");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pembayaran QRIS',
          style: GoogleFonts.poppins(color: Colors.white),
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
              ),
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
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Scan QR code di bawah untuk menyelesaikan pembayaran:',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Center(
              child: Image.network(
                widget.qrisUrl,
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 250,
                  height: 250,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      'Gagal memuat QR Code',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isChecking ? null : () => checkPaymentStatus(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B9B5E),
                ),
                child: _isChecking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Periksa Status Pembayaran',
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
