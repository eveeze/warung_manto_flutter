import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionDetailScreen extends StatelessWidget {
  final dynamic transaction;
  static const primaryColor = Color(0xFF093C25);
  static const secondaryColor = Color(0xFF1B9B5E);

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Transaction Details',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard([
                _buildDetailRow(
                    'Payment Type', transaction['paymentType'] ?? 'N/A'),
                _buildDetailRow(
                    'Total Cost', 'Rp ${transaction['totalCost'] ?? '0'}'),
                _buildDetailRow(
                    'Total Profit', 'Rp ${transaction['totalProfit'] ?? '0'}'),
                _buildDetailRow(
                    'Payment Status', transaction['paymentStatus'] ?? 'N/A'),
                if (transaction['paymentType'] == 'credit') ...[
                  _buildDetailRow(
                      'Buyer Name', transaction['buyerName'] ?? 'N/A'),
                  _buildDetailRow('Debt', 'Rp ${transaction['debt'] ?? '0'}'),
                ],
              ]),
              const SizedBox(height: 16),
              Text(
                'Products',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (transaction['products'] != null &&
                  transaction['products'].isNotEmpty)
                _buildProductsCard(transaction['products'])
              else
                _buildEmptyCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildProductsCard(List products) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          var product = products[index];
          var productData = product['product'];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              productData != null ? productData['name'] ?? 'N/A' : 'N/A',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Quantity: ${product['quantity'] ?? 0}',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            trailing: Text(
              'Profit: Rp ${product['profit'] ?? '0'}',
              style: GoogleFonts.poppins(
                  color: secondaryColor, fontWeight: FontWeight.w500),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No products available',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
