// lib/pages/add_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends StatefulWidget {
  final String token;
  final VoidCallback onSave;

  const AddScreen({
    Key? key,
    required this.token,
    required this.onSave,
  }) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _producerPriceController =
      TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? selectedCategoryId;
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
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
          categories = data; // Save categories list
        });
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  Future<void> addProduct() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/products'),
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
          'category': selectedCategoryId,
        }),
      );

      if (response.statusCode == 201) {
        widget.onSave();
        Navigator.pop(context); // Return to the previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }
    } catch (error) {
      print('Error adding product: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Produk',
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
        child: ListView(
          children: [
            _buildTextField(_nameController, 'Product Name'),
            _buildTextField(_stockController, 'Stock',
                keyboardType: TextInputType.number),
            _buildTextField(_minStockController, 'Minimum Stock',
                keyboardType: TextInputType.number),
            _buildTextField(_producerPriceController, 'Producer Price',
                keyboardType: TextInputType.number),
            _buildTextField(_salePriceController, 'Sale Price',
                keyboardType: TextInputType.number),
            _buildTextField(_descriptionController, 'Description'),
            _buildTextField(_imageUrlController, 'Image URL'),
            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
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
                labelText: 'Category',
                labelStyle: GoogleFonts.poppins(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: const Color(0xFF10B981),
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text(
                'Tambah Produk',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
