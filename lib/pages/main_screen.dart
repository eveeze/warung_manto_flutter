import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minggu_4/components/bottom_navigation_bar.dart';
import 'package:minggu_4/pages/crud_transaction_screen.dart';
import 'dart:convert';
import 'package:minggu_4/pages/edit_screen.dart';
import 'package:minggu_4/pages/add_screen.dart';
import 'package:minggu_4/pages/detail_screen.dart';
import 'package:minggu_4/pages/home.dart';
import 'package:minggu_4/pages/transaksi_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minggu_4/pages/user_screen.dart';

class MainScreen extends StatefulWidget {
  final String token;
  const MainScreen({super.key, required this.token});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late List<Widget> _screens;
  String? userName;
  List<dynamic> products = [];
  List<dynamic> categories = [];
  Map<String, int> cart = {};
  bool isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  final TextEditingController _searchController = TextEditingController();

  String? selectedCategory;
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 1000000);
  RangeValues _stockRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Then create the animation using the controller
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _screens = [
      HomesScreen(token: widget.token),
      MainScreen(token: widget.token),
      CrudTransactionScreen(token: widget.token),
      UserScreen(token: widget.token)
    ];
    _initializeScreen();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://103.127.138.32/api/products?page=${_currentPage + 1}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newProducts = data['products'] as List;

        setState(() {
          products.addAll(newProducts);
          _currentPage++;
          _totalPages = data['pagination']['totalPages'];
          _hasMoreData = _currentPage < _totalPages;
          _isLoadingMore = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoadingMore = false;
      });
      print('Error loading more products: $error');
    }
  }

  Future<void> _initializeScreen() async {
    await Future.wait([
      fetchUserData(),
      fetchProducts(),
      fetchCategories(),
    ]);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
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
        if (data is List) {
          setState(() {
            categories = data;
          });
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
    int page = 1,
  }) async {
    setState(() {
      isLoading = true;
      _currentPage = page;
    });

    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': '10', // Adjust limit as needed
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (minPrice != null) queryParams['minSalePrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxSalePrice'] = maxPrice.toString();
      if (minStock != null) queryParams['minStock'] = minStock.toString();
      if (maxStock != null) queryParams['maxStock'] = maxStock.toString();

      String queryString = Uri(queryParameters: queryParams).query;
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/products?$queryString'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['products'];
          _totalPages = data['pagination']['totalPages'];
          _hasMoreData = data['pagination']['hasNextPage'];
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

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Page Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _currentPage > 1
                ? () => fetchProducts(page: _currentPage - 1)
                : null,
          ),

          // Current Page Indicator
          Text(
            'Page $_currentPage of $_totalPages',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),

          // Next Page Button
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentPage < _totalPages
                ? () => fetchProducts(page: _currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index != _currentIndex) {
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomesScreen(token: widget.token)),
        );
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CrudTransactionScreen(token: widget.token)),
        );
      } else if (index == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserScreen(token: widget.token)),
        );
      }
      setState(() {
        _currentIndex = index;
      });
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
          SnackBar(
            content: Text(
              'Produk berhasil dihapus',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Produk ditambahkan ke keranjang',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF093C25),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF093C25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
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
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _priceRange = const RangeValues(0, 1000000);
                            _stockRange = const RangeValues(0, 1000);
                          });
                        },
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        label: Text(
                          'Reset',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: const Color(0xFF093C25),
                      hint: Text(
                        'Pilih Kategori',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      value: _selectedCategory,
                      style: GoogleFonts.poppins(color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      underline: const SizedBox(),
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
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rentang Harga',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RangeSlider(
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
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
                  const SizedBox(height: 20),
                  Text(
                    'Rentang Stok',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RangeSlider(
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF093C25),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
          productId: product['_id'],
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
          onSave: fetchProducts,
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
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap,
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
            if (!isLoading) _buildPaginationControls(),
            if (_isLoadingMore)
              const LinearProgressIndicator(
                backgroundColor: Color(0xFF093C25),
              ),
          ],
        ));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: const Color(0xFF093C25),
      titleSpacing: 20,
      title: Text(
        'Kelola Produk',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _buildSearchBar(),
      ),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _buildSearchClearButton(),
                ),
                onChanged: (value) => fetchProducts(search: value),
              ),
            ),
          ),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSearchClearButton() {
    return _searchController.text.isNotEmpty
        ? AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                _searchController.clear();
                fetchProducts();
              },
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildFilterButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.white),
        onPressed: _showFilterBottomSheet,
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon:
            const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
        onPressed: navigateToAddScreen,
      ),
      Stack(
        alignment: Alignment.topRight,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 28),
            onPressed: navigateToTransactionScreen,
          ),
          if (cart.isNotEmpty) _buildCartBadge(),
        ],
      ),
    ];
  }

  Widget _buildCartBadge() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        cart.values.reduce((a, b) => a + b).toString(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF093C25)),
        ),
      );
    }

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => _buildProductCard(products[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada produk ditemukan',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter pencarian Anda',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Hero(
      tag: 'product-${product['_id']}',
      child: Material(
        elevation: 4,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(product: product),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(product),
                _buildProductInfo(product),
                _buildProductActions(product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        image: DecorationImage(
          image: NetworkImage(
              product['imageUrl'] ?? 'https://via.placeholder.com/150'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductInfo(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product['name'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Rp${product['salePrice'].toString()}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF093C25),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Stok: ${product['stock']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductActions(Map<String, dynamic> product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: Colors.blue,
          onPressed: () => navigateToEditScreen(product),
        ),
        _buildActionButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          onPressed: () => deleteProduct(product['_id']),
        ),
        if (product['status'] == 'active')
          _buildActionButton(
            icon: Icons.add_shopping_cart_outlined,
            color: const Color(0xFF093C25),
            onPressed: () => addToCart(product['_id']),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}
