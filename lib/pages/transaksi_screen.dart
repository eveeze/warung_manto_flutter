// lib/pages/transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:minggu_4/pages/cash_screen.dart';
import 'package:minggu_4/pages/qris_screen.dart';

class TransaksiScreen extends StatefulWidget {
  final String token;
  final Map<String, int> cart;
  final ValueChanged<Map<String, int>> onCartUpdate;

  const TransaksiScreen({
    Key? key,
    required this.token,
    required this.cart,
    required this.onCartUpdate,
  }) : super(key: key);

  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  Map<String, int> updatedCart = {};
  Map<String, dynamic> productDetails = {};
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  @override
  void initState() {
    super.initState();
    updatedCart = Map.from(widget.cart); // Copy cart data
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    final ids = updatedCart.keys.join(',');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/products?ids=$ids'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    print('Response body: ${response.body}'); // Cek isi respons sebelum parsing

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List products = responseBody['products'];
        setState(() {
          for (var product in products) {
            productDetails[product['_id']] = product;
          }
        });
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      print(
          'Failed to load product details. Status code: ${response.statusCode}');
    }
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

  void proceedToPayment(String paymentType) async {
    // Calculate items and total cost once
    final items = updatedCart.entries.map((entry) {
      final product = productDetails[entry.key];
      return {
        'productId': entry.key,
        'productName':
            product != null ? product['name'] : 'Product ${entry.key}',
        'quantity': entry.value,
        'price': product != null
            ? (product['salePrice'] as num).toDouble()
            : 10000.0,
      };
    }).toList();

    final totalCost = items.fold<double>(
      0,
      (sum, item) =>
          sum + ((item['price'] as double) * (item['quantity'] as int)),
    );

    if (paymentType == 'qris') {
      // Handle QRIS payment
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/transaction/purchase'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'items': items
              .map((item) => {
                    'productId': item['productId'],
                    'quantity': item['quantity']
                  })
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
                setState(() {
                  updatedCart.clear();
                  widget.onCartUpdate(updatedCart);
                });
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QRIS transaction failed: ${response.body}')),
        );
      }
    } else if (paymentType == 'cash') {
      // Handle cash payment without changes
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CashScreen(
            items: items,
            totalCost: totalCost,
            paymentType: paymentType,
            token: widget.token,
            onPaymentComplete: (_) {
              setState(() {
                updatedCart.clear();
                widget.onCartUpdate(updatedCart);
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: updatedCart.keys.length,
        itemBuilder: (context, index) {
          final productId = updatedCart.keys.elementAt(index);
          final quantity = updatedCart[productId] ?? 0;
          final product = productDetails[productId];
          final productName =
              product != null ? product['name'] : 'Product ID: $productId';
          final productPrice = product != null ? product['salePrice'] : 0.0;

          return ListTile(
            title: Text(productName),
            subtitle: Text(
                'Harga: ${formatCurrency.format(productPrice)}\nQuantity: $quantity'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => adjustQuantity(productId, -1),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => adjustQuantity(productId, 1),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => proceedToPayment("cash"),
              child: const Text("Cash"),
            ),
            ElevatedButton(
              onPressed: () => proceedToPayment("credit"),
              child: const Text("Credit"),
            ),
            ElevatedButton(
              onPressed: () => proceedToPayment("qris"),
              child: const Text("QRIS"),
            ),
          ],
        ),
      ),
    );
  }
}
