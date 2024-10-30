// lib/pages/edit_screen.dart
// lib/pages/edit_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class EditScreen extends StatefulWidget {
  final String token;
  final String productId; // Product ID for editing
  final VoidCallback? onSave; // Callback to refresh product list

  const EditScreen({
    Key? key,
    required this.token,
    required this.productId,
    this.onSave,
  }) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _producerPriceController =
      TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String? selectedCategory;
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    if (widget.productId.isNotEmpty) {
      fetchProductDetails();
    }
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/categories'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          categories = data;
        });
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/products/${widget.productId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nameController.text = data['name'];
          _stockController.text = data['stock'].toString();
          _minStockController.text = data['minStock'].toString();
          _producerPriceController.text = data['producerPrice'].toString();
          _salePriceController.text = data['salePrice'].toString();
          _descriptionController.text = data['description'];
          _imageUrlController.text = data['imageUrl'];
          selectedCategory = data['category'];
        });
      } else {
        print('Failed to fetch product details');
      }
    } catch (error) {
      print('Error fetching product details: $error');
    }
  }

  Future<void> updateProduct() async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/products/${widget.productId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode({
          'name': _nameController.text,
          'stock': int.parse(_stockController.text),
          'minStock': int.parse(_minStockController.text),
          'producerPrice': double.parse(_producerPriceController.text),
          'salePrice': double.parse(_salePriceController.text),
          'description': _descriptionController.text,
          'imageUrl': _imageUrlController.text,
          'category': selectedCategory,
        }),
      );

      if (response.statusCode == 200) {
        widget.onSave?.call();
        Navigator.pop(context, true);
      } else {
        print('Failed to update product');
      }
    } catch (error) {
      print('Error updating product: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Produk',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF093C25),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Nama Produk'),
              _buildTextField(_stockController, 'Stok',
                  keyboardType: TextInputType.number),
              _buildTextField(_minStockController, 'Stok Minimum',
                  keyboardType: TextInputType.number),
              _buildTextField(_producerPriceController, 'Harga Produsen',
                  keyboardType: TextInputType.number),
              _buildTextField(_salePriceController, 'Harga Jual',
                  keyboardType: TextInputType.number),
              _buildTextField(_descriptionController, 'Deskripsi', maxLines: 3),
              _buildTextField(_imageUrlController, 'URL Gambar'),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['_id'],
                    child: Text(
                      category['name'],
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  labelStyle: GoogleFonts.poppins(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    updateProduct();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: const Color(0xFF10B981),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  'Perbarui Produk',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _producerPriceController.dispose();
    _salePriceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
