import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class QRISScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double totalCost;
  final String qrisUrl;
  final String orderId;
  final String token;
  final ValueChanged<void> onPaymentComplete;
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  QRISScreen({
    Key? key,
    required this.items,
    required this.totalCost,
    required this.qrisUrl,
    required this.orderId,
    required this.token,
    required this.onPaymentComplete,
  }) : super(key: key);

  Future<void> checkPaymentStatus(BuildContext context) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/transaction/qris-status/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['transactionStatus'] == 'completed') {
        onPaymentComplete(null);
        Navigator.pushReplacementNamed(context, '/success');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Print QR URL for simulation
    print("QR URL for simulation: $qrisUrl");

    return Scaffold(
      appBar: AppBar(
        title: const Text('QRIS Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...items.map((item) => ListTile(
                  title: Text(item['productName']),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                  trailing:
                      Text('Price: ${formatCurrency.format(item['price'])}'),
                )),
            const Divider(),
            Text(
              'Total Cost: ${formatCurrency.format(totalCost)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan the QR code below to complete payment:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Center(
              child: Image.network(
                qrisUrl,
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Failed to load QR code'),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => checkPaymentStatus(context), // Pass context here
              child: const Text('Check Payment Status'),
            ),
          ],
        ),
      ),
    );
  }
}
