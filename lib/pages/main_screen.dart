import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:minggu_4/pages/edit_screen.dart';
import 'package:minggu_4/pages/add_screen.dart';
import 'package:minggu_4/pages/detail_screen.dart';
import 'package:minggu_4/pages/home_screen.dart';
import 'package:minggu_4/pages/transaksi_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minggu_4/service/auth_service.dart';

class MainScreen extends StatefulWidget {
  final String token;

  const MainScreen({
    super.key,
    required this.token,
  });

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

  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 1000000);
  RangeValues _stockRange = const RangeValues(0, 1000);
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
        Uri.parse('http://103.127.138.32/api/auth/user-profile'),
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
        Uri.parse('http://103.127.138.32/api/categories'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Assuming `data` is the array itself, not wrapped inside another object
        if (data is List) {
          // Ensure that `data` is a list
          setState(() {
            categories = data;
          });
        } else {
          print('Unexpected data format: expected a list of categories');
        }
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  Future<void> fetchProducts({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
  }) async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, String> queryParams = {};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (minPrice != null) {
        queryParams['minSalePrice'] = minPrice.toString();
      }

      if (maxPrice != null) {
        queryParams['maxSalePrice'] = maxPrice.toString();
      }

      if (minStock != null) {
        queryParams['minStock'] = minStock.toString();
      }

      if (maxStock != null) {
        queryParams['maxStock'] = maxStock.toString();
      }

      String queryString = Uri(queryParameters: queryParams).query;

      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/products?$queryString'),
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
        Uri.parse('http://103.127.138.32/api/products'),
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
        Uri.parse('http://103.127.138.32/api/products/$id'),
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
        Uri.parse('http://103.127.138.32/api/products/$id'),
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

  Future<void> logout() async {
    try {
      await AuthService.logout(widget.token);
      // Navigate back to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const HomeScreen()), // Replace with your login page
      );
    } catch (e) {
      // Handle error (e.g., show a message)
      print('Logout error: $e');
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF093C25),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF093C25),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Produk',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _priceRange = const RangeValues(0, 1000000);
                            _stockRange = const RangeValues(0, 1000);
                          });
                        },
                        child: Text(
                          'Reset Filter',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF093C25),
                    hint: Text(
                      'Pilih Kategori',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    value: _selectedCategory,
                    style: GoogleFonts.poppins(color: Colors.white),
                    iconEnabledColor: Colors.white,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Semua Kategori'),
                      ),
                      ...categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['_id'],
                          child: Text(category['name']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  Text(
                    'Rentang Harga',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  RangeSlider(
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.3),
                    values: _priceRange,
                    min: 0,
                    max: 1000000,
                    divisions: 100,
                    labels: RangeLabels(
                      'Rp${_priceRange.start.round()}',
                      'Rp${_priceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Text(
                    'Rentang Stok',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  RangeSlider(
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.3),
                    values: _stockRange,
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    labels: RangeLabels(
                      '${_stockRange.start.round()}',
                      '${_stockRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _stockRange = values;
                      });
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF093C25),
                    ),
                    onPressed: () {
                      fetchProducts(
                        search: _searchController.text,
                        category: _selectedCategory,
                        minPrice: _priceRange.start,
                        maxPrice: _priceRange.end,
                        minStock: _stockRange.start.toInt(),
                        maxStock: _stockRange.end.toInt(),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Terapkan Filter',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFF093C25),
        titleSpacing: 20,
        title: Text(
          'Kelola Produk',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        hintText: 'Cari produk',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white70,
                          letterSpacing: 1.1,
                        ),
                        border: InputBorder.none,
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.white),
                                onPressed: () {
                                  _searchController.clear();
                                  fetchProducts();
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        fetchProducts(search: value);
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                      ),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), // Logout icon
            onPressed: logout, // Call logout method
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => navigateToAddScreen(),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () => navigateToTransactionScreen(),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.values.reduce((a, b) => a + b).toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_basket,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada produk ditemukan',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(product['imageUrl'] ??
                                        'https://via.placeholder.com/150'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp${product['salePrice']}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stok: ${product['stock']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue, size: 20),
                                        onPressed: () =>
                                            navigateToEditScreen(product),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        onPressed: () =>
                                            deleteProduct(product['_id']),
                                      ),
                                      if (product['status'] == 'active')
                                        IconButton(
                                          icon: const Icon(Icons.add_circle,
                                              color: Colors.green, size: 20),
                                          onPressed: () =>
                                              addToCart(product['_id']),
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
