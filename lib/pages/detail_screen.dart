// lib/pages/detail_screen.dart
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const DetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk Utama
            Center(
              child: Image.network(
                product['imageUrl'] ?? 'https://via.placeholder.com/150',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // Harga Produk
            Text(
              'Rp ${product['salePrice']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            // Nama Produk
            Text(
              product['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // Deskripsi Produk
            Text(
              product['description'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            // Detail Produk
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildDetailCard('Stock', product['stock'].toString()),
                _buildDetailCard('Min Stock', product['minStock'].toString()),
                _buildDetailCard('Harga', 'Rp ${product['salePrice']}'),
                _buildDetailCard(
                    'Harga Asal', 'Rp ${product['producerPrice']}'),
                _buildDetailCard(
                    'Kategori', product['category']?['name'] ?? ''),
                _buildDetailCard('Status', product['status']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
