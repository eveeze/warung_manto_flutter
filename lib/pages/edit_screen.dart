import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditScreen extends StatefulWidget {
  final String token;
  final String productId;
  final VoidCallback? onSave;

  const EditScreen({
    super.key,
    required this.token,
    required this.productId,
    this.onSave,
  });

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
  String? selectedStatus;
  List<dynamic> categories = [];
  final List<String> statuses = ['active', 'inactive'];
  bool _isLoading = false;

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
        Uri.parse('http://103.127.138.32/api/categories'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (mounted) {
          setState(() {
            categories = data;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('Gagal memuat kategori');
      }
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/products/${widget.productId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _nameController.text = data['name'];
            _stockController.text = data['stock'].toString();
            _minStockController.text = data['minStock'].toString();
            _producerPriceController.text = data['producerPrice'].toString();
            _salePriceController.text = data['salePrice'].toString();
            _descriptionController.text = data['description'];
            _imageUrlController.text = data['imageUrl'];
            selectedCategory = data['category'];
            selectedStatus = data['status'];
          });
        }
      } else {
        _showErrorSnackBar('Gagal memuat detail produk');
      }
    } catch (error) {
      _showErrorSnackBar('Terjadi kesalahan');
    }
  }

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('http://103.127.138.32/api/products/${widget.productId}'),
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
          'status': selectedStatus,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        widget.onSave?.call();
        Navigator.pop(context, true);
        _showSuccessSnackBar('Produk berhasil diperbarui');
      } else {
        _showErrorSnackBar('Gagal memperbarui produk');
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
          'Edit Produk',
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
                    'public/edits.svg',
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
                  label: 'Harga Produsen',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Harga produsen wajib diisi' : null,
                ),
                _buildTextFormField(
                  controller: _salePriceController,
                  label: 'Harga Jual',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Harga jual wajib diisi' : null,
                ),
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'Deskripsi',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Deskripsi wajib diisi' : null,
                ),
                _buildTextFormField(
                  controller: _imageUrlController,
                  label: 'URL Gambar',
                  icon: Icons.image,
                  validator: (value) =>
                      value!.isEmpty ? 'URL gambar wajib diisi' : null,
                ),
                const SizedBox(height: 5),

                // Dropdown for Category
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

                // Dropdown for Status
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                  items: statuses.map<DropdownMenuItem<String>>((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Status Produk',
                    labelStyle: GoogleFonts.poppins(fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Update Button
                ElevatedButton(
                  onPressed: _isLoading ? null : updateProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: const Color(0xFF10B981),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Perbarui Produk',
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
            borderSide: const BorderSide(color: Color(0xFF1B9B5E), width: 2),
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
