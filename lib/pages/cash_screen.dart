// lib/pages/cash_screen.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalCost;
  final String paymentType;
  final String token;
  final ValueChanged<void> onPaymentComplete;

  const CashScreen({
    Key? key,
    required this.items,
    required this.totalCost,
    required this.paymentType,
    required this.token,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  _CashScreenState createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  double amountPaid = 0.0;
  double change = 0.0;
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  void calculateChange() {
    setState(() {
      change = amountPaid - widget.totalCost;
    });
  }

  Future<void> completePayment() async {
    if (amountPaid < widget.totalCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient payment amount')),
      );
      return;
    }

    final transactionData = {
      'items': widget.items
          .map((item) => {
                'productId': item['productId'],
                'quantity': item['quantity'],
              })
          .toList(),
      'paymentType': widget.paymentType,
      'amountPaid': amountPaid,
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/transaction/purchase'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(transactionData),
    );

    if (response.statusCode == 201) {
      widget.onPaymentComplete(null);
      Navigator.pushReplacementNamed(context, '/success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction failed: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Payment'),
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
            ...widget.items.map((item) => ListTile(
                  title: Text(item['productName']),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                  trailing:
                      Text('Price: ${formatCurrency.format(item['price'])}'),
                )),
            const Divider(),
            Text(
              'Total Cost: ${formatCurrency.format(widget.totalCost)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount Paid'),
              onChanged: (value) {
                setState(() {
                  amountPaid = double.tryParse(value) ?? 0.0;
                  calculateChange();
                });
              },
            ),
            const SizedBox(height: 10),
            Text('Change: ${formatCurrency.format(change)}'),
            const Spacer(),
            ElevatedButton(
              onPressed: completePayment,
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
