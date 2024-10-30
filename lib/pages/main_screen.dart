import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:minggu_4/pages/edit_screen.dart';
import 'package:minggu_4/pages/add_screen.dart';
import 'package:minggu_4/pages/detail_screen.dart';
import 'package:minggu_4/pages/transaksi_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Tambahkan ini

class MainScreen extends StatefulWidget {
  final String token;

  const MainScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? userName;
  List<dynamic> products = [];
  List<dynamic> categories = [];
  Map<String, int> cart = {};
  bool isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _producerPriceController =
      TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/auth/user-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['name'];
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/categories'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data['categories'];
        });
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/products'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['products'];
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching products: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addProduct() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/products'),
        headers: {'Content-Type': 'application/json'},
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

      if (response.statusCode == 201) {
        fetchProducts();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }
    } catch (error) {
      print('Error adding product: $error');
    }
  }

  Future<void> updateProduct(String id) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/products/$id'),
        headers: {'Content-Type': 'application/json'},
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
        fetchProducts();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      }
    } catch (error) {
      print('Error updating product: $error');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/products/$id'),
      );

      if (response.statusCode == 200) {
        fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    } catch (error) {
      print('Error deleting product: $error');
    }
  }

  void addToCart(String productId) {
    setState(() {
      cart[productId] = (cart[productId] ?? 0) + 1;
    });
  }

  void navigateToEditScreen(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          token: widget.token,
          productId: product['_id'] ?? '', // Optional productId for new product
          onSave: fetchProducts,
        ),
      ),
    );
  }

  void navigateToAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScreen(
          token: widget.token,
          onSave: fetchProducts, // Callback to refresh product list
        ),
      ),
    );
  }

  void navigateToTransactionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransaksiScreen(
          token: widget.token,
          cart: cart,
          onCartUpdate: (updatedCart) {
            setState(() {
              cart = updatedCart;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF093C25),
        title: Text(
          'Kelola Produk',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.add, color: Colors.white), // Icon warna putih
            onPressed: () => navigateToAddScreen(),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart,
                    color: Colors.white), // Icon warna putih
                onPressed: () => navigateToTransactionScreen(),
              ),
              if (cart.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    cart.values.reduce((a, b) => a + b).toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(product: product),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(product['imageUrl'] ??
                                    'https://via.placeholder.com/150'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Rp${product['salePrice']}',
                                style: GoogleFonts.poppins(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Stock: ${product['stock']}',
                                style: GoogleFonts.poppins(),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        navigateToEditScreen(product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        deleteProduct(product['_id']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    onPressed: () => addToCart(product['_id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
