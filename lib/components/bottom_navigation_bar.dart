// components/bottom_navigation_bar.dart

import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF093C25), // Background color of the nav bar
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), // Rounded top-left corner
          topRight: Radius.circular(20), // Rounded top-right corner
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Subtle shadow for lifted effect
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor:
            const Color(0xFF00A86B), // Selected icon color (teal)
        unselectedItemColor: Colors.white, // Inactive icon color
        backgroundColor:
            const Color(0xFF093C25), // Background color of the nav bar
        selectedLabelStyle: const TextStyle(
          color: Colors.white, // Color of label text when selected
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.white, // Color of label text when unselected
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
