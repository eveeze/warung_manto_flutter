// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:minggu_4/components/bottom_navigation_bar.dart';
import 'package:minggu_4/pages/crud_transaction_screen.dart';
import 'package:minggu_4/pages/home.dart';
import 'package:minggu_4/pages/home_screen.dart';
import 'package:minggu_4/pages/main_screen.dart';
import 'package:minggu_4/service/auth_service.dart';

class UserScreen extends StatefulWidget {
  final String token;
  const UserScreen({
    super.key,
    required this.token,
  });

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _currentIndex = 3;
  late List<Widget> _screens;
  late List<dynamic> users = [];
  String? userId;
  String? userName;
  String? nomorHandphone;
  String? verified;
  String? createdAt;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomesScreen(token: widget.token),
      MainScreen(token: widget.token),
      CrudTransactionScreen(token: widget.token),
      UserScreen(token: widget.token)
    ];

    fetchUserData();
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
          userId = data['_id'];
          userName = data['name'];
          nomorHandphone = data['phone'].toString();
          verified = data['isVerified'].toString();
          createdAt = data['createdAt'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Gagal mengambil data pengguna');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Error: $error');
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout(widget.token);
      // Navigate back to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const HomeScreen(), // Replace with your login page
        ),
      );
    } catch (e) {
      // Handle error (e.g., show a message)
      print('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> getAllUser() async {
    try {
      final response = await http.get(
        Uri.parse('http://103.127.138.32/api/auth/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> userData = json.decode(response.body);
        setState(() {
          users = userData;
        });
      } else {
        _showErrorDialog('Gagal mengambil data semua pengguna');
      }
    } catch (error) {
      _showErrorDialog('Error: $error');
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomesScreen(token: widget.token)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(token: widget.token)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CrudTransactionScreen(token: widget.token)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserScreen(token: widget.token)),
        );
        break;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terjadi Kesalahan'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Oke'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Akun'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus akun ini?'),
                Text('Tindakan ini tidak dapat dibatalkan.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('http://103.127.138.32/api/auth/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting account')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profil Pengguna',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF093C25),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildProfileSection(),
                  const SizedBox(height: 20),
                  _buildDeleteAccountButton(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: getAllUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF157B3E),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    child: Text(
                      'Get All Users',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  users.isNotEmpty
                      ? _buildUserList()
                      : Center(
                          child: Text(
                            'No users available',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                ],
              ),
            ),
      bottomNavigationBar:
          BottomNavBar(currentIndex: _currentIndex, onTap: _onBottomNavTap),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF00A86B),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            userName ?? 'Nama Pengguna',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF157B3E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileItem(
                'Nomor Handphone', nomorHandphone ?? 'Tidak tersedia'),
            const Divider(color: Colors.grey),
            _buildProfileItem('Verifikasi',
                verified == 'true' ? 'Terverifikasi' : 'Belum Terverifikasi'),
            const Divider(color: Colors.grey),
            _buildProfileItem(
                'Bergabung Sejak',
                DateFormat(DateFormat.YEAR_MONTH_DAY)
                    .format(DateTime.parse(createdAt!))),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF00A86B),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              user['name'] ?? 'Unknown User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF157B3E),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone: ${user['phone']}',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                Text(
                  user['isVerified'] == true ? 'Verified' : 'Not Verified',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Color(0xFF157B3E)),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF157B3E),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF00A86B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _showDeleteAccountConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
        ),
        child: Text(
          'Hapus Akun',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
