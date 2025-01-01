// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:minggu_4/components/bottom_navigation_bar.dart';
import 'package:minggu_4/pages/edit_transaction_screen.dart';
import 'transaksi_detail_screen.dart';
import 'package:minggu_4/pages/home.dart';
import 'package:minggu_4/pages/user_screen.dart';
import 'package:minggu_4/pages/main_screen.dart';

class CrudTransactionScreen extends StatefulWidget {
  final String token;

  const CrudTransactionScreen({super.key, required this.token});

  @override
  _CrudTransactionScreenState createState() => _CrudTransactionScreenState();
}

class _CrudTransactionScreenState extends State<CrudTransactionScreen> {
  int _currentIndex = 2;
  late List<Widget> _screens;
  List<dynamic> transactions = [];
  bool isLoading = true;
  String? selectedPaymentType;
  String? selectedPaymentStatus;

  // Filter controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final Color primaryColor = const Color(0xFF093C25);
  final Color secondaryColor = const Color(0xFF157B3E);
  final Color textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomesScreen(token: widget.token),
      MainScreen(token: widget.token),
      CrudTransactionScreen(token: widget.token),
      UserScreen(token: widget.token)
    ];
    fetchTransactions();
  }

  Future<void> fetchTransactions({
    String? paymentType,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, String> queryParams = {};

      if (paymentType != null) queryParams['paymentType'] = paymentType;
      if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      String queryString = Uri(queryParameters: queryParams).query;
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/transaction?$queryString'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = data['transactions'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (error) {
      print('Error fetching transactions: $error');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load transactions')),
      );
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://103.127.138.32/api/transaction/$transactionId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        fetchTransactions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete transaction');
      }
    } catch (error) {
      print('Error deleting transaction: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete transaction')),
      );
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              color: primaryColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filter Transactions',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Payment Type',
                      labelStyle: TextStyle(color: textColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor)),
                    ),
                    dropdownColor: primaryColor,
                    value: selectedPaymentType,
                    items: ['cash', 'credit', 'qris']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase(),
                                  style: TextStyle(color: textColor)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Payment Status',
                      labelStyle: TextStyle(color: textColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor)),
                    ),
                    dropdownColor: primaryColor,
                    value: selectedPaymentStatus,
                    items: ['pending', 'completed', 'failed']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.toUpperCase(),
                                  style: TextStyle(color: textColor)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            labelStyle: TextStyle(color: textColor),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: secondaryColor)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondaryColor)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor)),
                          ),
                          style: TextStyle(color: textColor),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              _startDateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            labelStyle: TextStyle(color: textColor),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: secondaryColor)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondaryColor)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor)),
                          ),
                          style: TextStyle(color: textColor),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              _endDateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                          ),
                          onPressed: () {
                            fetchTransactions(
                              paymentType: selectedPaymentType,
                              paymentStatus: selectedPaymentStatus,
                              startDate: _startDateController.text.isNotEmpty
                                  ? DateTime.parse(_startDateController.text)
                                  : null,
                              endDate: _endDateController.text.isNotEmpty
                                  ? DateTime.parse(_endDateController.text)
                                  : null,
                            );
                            Navigator.pop(context);
                          },
                          child: Text('Apply Filter',
                              style: TextStyle(color: textColor)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: secondaryColor),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedPaymentType = null;
                              selectedPaymentStatus = null;
                              _startDateController.clear();
                              _endDateController.clear();
                            });
                            fetchTransactions();
                            Navigator.pop(context);
                          },
                          child:
                              Text('Reset', style: TextStyle(color: textColor)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToTransactionDetailScreen(dynamic transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Text('Transactions',
            style: GoogleFonts.poppins(
                color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found',
                    style: GoogleFonts.poppins(color: primaryColor),
                  ),
                )
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return GestureDetector(
                      onTap: () =>
                          _navigateToTransactionDetailScreen(transaction),
                      child: Card(
                        color: textColor,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: secondaryColor),
                        ),
                        child: ListTile(
                          title: Text(
                            'Transaction #${transaction['_id']}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type: ${transaction['paymentType']}',
                                style: GoogleFonts.poppins(color: primaryColor),
                              ),
                              Text(
                                'Total: Rp ${transaction['totalCost']}',
                                style: GoogleFonts.poppins(color: primaryColor),
                              ),
                              Text(
                                'Status: ${transaction['paymentStatus']}',
                                style: GoogleFonts.poppins(
                                  color: transaction['paymentStatus'] ==
                                          'completed'
                                      ? secondaryColor
                                      : transaction['paymentStatus'] ==
                                              'pending'
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTransactionScreen(
                                      token: widget.token,
                                      transaction: transaction,
                                    ),
                                  ),
                                ).then((result) {
                                  // Refresh transactions if edit was successful
                                  if (result == true) {
                                    fetchTransactions();
                                  }
                                }),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    deleteTransaction(transaction['_id']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar:
          BottomNavBar(currentIndex: _currentIndex, onTap: _onBottomNavTap),
    );
  }
}
