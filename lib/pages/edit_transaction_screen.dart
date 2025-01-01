import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditTransactionScreen extends StatefulWidget {
  final String token;
  final dynamic transaction;

  const EditTransactionScreen({
    super.key,
    required this.token,
    required this.transaction,
  });

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final Color primaryColor = const Color(0xFF093C25);
  final Color secondaryColor = const Color(0xFF157B3E);
  final Color textColor = Colors.white;

  // Form controllers
  late TextEditingController _paymentTypeController;
  late TextEditingController _paymentStatusController;
  late TextEditingController _totalCostController;
  late TextEditingController _buyerNameController;
  late TextEditingController _debtController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing transaction data
    _paymentTypeController =
        TextEditingController(text: widget.transaction['paymentType'] ?? '');
    _paymentStatusController =
        TextEditingController(text: widget.transaction['paymentStatus'] ?? '');
    _totalCostController = TextEditingController(
        text: widget.transaction['totalCost']?.toString() ?? '');
    _buyerNameController =
        TextEditingController(text: widget.transaction['buyerName'] ?? '');
    _debtController = TextEditingController(
        text: widget.transaction['debt']?.toString() ?? '');
  }

  Future<void> _updateTransaction() async {
    try {
      final response = await http.put(
        Uri.parse('http://103.127.138.32/api/transaction/update'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'transactionId': widget.transaction['_id'],
          'paymentType': _paymentTypeController.text,
          'paymentStatus': _paymentStatusController.text,
          'totalCost': double.tryParse(_totalCostController.text) ?? 0,
          'buyerName': _buyerNameController.text,
          'debt': double.tryParse(_debtController.text) ?? 0,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction updated successfully',
                style: GoogleFonts.poppins(color: textColor)),
            backgroundColor: secondaryColor,
          ),
        );
        Navigator.pop(context, true); // Return to previous screen with success
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'Failed to update transaction';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage,
                style: GoogleFonts.poppins(color: textColor)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error updating transaction: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating transaction',
              style: GoogleFonts.poppins(color: textColor)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Edit Transaction',
          style: GoogleFonts.poppins(color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownField(
              'Payment Type',
              _paymentTypeController,
              ['cash', 'credit', 'qris'],
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Payment Status',
              _paymentStatusController,
              ['pending', 'completed', 'failed'],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Total Cost',
              _totalCostController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Buyer Name',
              _buyerNameController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Debt',
              _debtController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Update Transaction',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: primaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    TextEditingController controller,
    List<String> options,
  ) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
      items: options
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(
                  option.toUpperCase(),
                  style: GoogleFonts.poppins(color: primaryColor),
                ),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _paymentTypeController.dispose();
    _paymentStatusController.dispose();
    _totalCostController.dispose();
    _buyerNameController.dispose();
    _debtController.dispose();
    super.dispose();
  }
}
