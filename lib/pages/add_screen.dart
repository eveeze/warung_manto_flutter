import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddScreen extends StatefulWidget {
  final String token;
  final VoidCallback onSave;

  const AddScreen({
    super.key,
    required this.token,
    required this.onSave,
  });

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/categories'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          categories = data;
        });
      }
    } catch (error) {
      _showErrorSnackBar('Gagal memuat kategori');
    }
  }

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://103.127.138.32/api/products'),
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

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        widget.onSave();
        Navigator.pop(context);
        _showSuccessSnackBar('Produk berhasil ditambahkan');
      } else {
        _showErrorSnackBar('Gagal menambahkan produk');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Terjadi kesalahan');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF093C25),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Produk Baru',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header Ilustrasi
                Center(
                  child: SvgPicture.asset(
                    'public/add.svg',
                    height: 200,
                  ),
                ),
                const SizedBox(height: 20),

                // Input Fields
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Nama Produk',
                  icon: Icons.shopping_bag,
                  validator: (value) =>
                      value!.isEmpty ? 'Nama produk wajib diisi' : null,
                ),
                _buildTextFormField(
                  controller: _stockController,
                  label: 'Stok',
                  icon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Stok wajib diisi' : null,
                ),
                _buildTextFormField(
                  controller: _minStockController,
                  label: 'Stok Minimal',
                  icon: Icons.warning,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Stok minimal wajib diisi' : null,
                ),
                _buildTextFormField(
                  controller: _producerPriceController,
                  label: 'Harga Produksi',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Harga produksi wajib diisi' : null,
                ),
                _buildTextFormField(
                  controller: _salePriceController,
                  label: 'Harga Jual',
                  icon: Icons.monetization_on,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Harga jual wajib diisi' : null,
                ),
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'Deskripsi',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                _buildTextFormField(
                  controller: _imageUrlController,
                  label: 'URL Gambar',
                  icon: Icons.image,
                ),

                // Dropdown Kategori
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.category,
                          color: const Color(0xFF093C25).withOpacity(0.7)),
                      labelText: 'Kategori',
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF093C25).withOpacity(0.7),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1B9B5E), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: const Color(0xFF093C25).withOpacity(0.3)),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category['_id'],
                        child: Text(
                          category['name'],
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF093C25)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Kategori wajib dipilih' : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Tambah Produk
                ElevatedButton(
                  onPressed: _isLoading ? null : addProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: const Color(0xFF1B9B5E),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Tambah Produk',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF093C25).withOpacity(0.7))
              : null,
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF093C25).withOpacity(0.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                const BorderSide(color: Color(0xFF1B9B5E), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: const Color(0xFF093C25).withOpacity(0.3)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        cursorColor: const Color(0xFF1B9B5E),
        style: GoogleFonts.poppins(color: const Color(0xFF093C25)),
        validator: validator,
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
