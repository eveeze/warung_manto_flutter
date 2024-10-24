// verify_pages.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:minggu_4/pages/main_screen.dart';

class VerifyPage extends StatefulWidget {
  final String phone;
  final String name;

  const VerifyPage({
    super.key,
    required this.phone,
    required this.name,
  });

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final otpController = TextEditingController();
  bool isLoading = false;
  bool isResending = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void showMessage(String message, {bool isError = true}) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isError ? 'Error' : 'Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty) {
      showMessage("Kode OTP tidak boleh kosong!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': widget.phone,
          'otp': otpController.text,
        }),
      );

      final data = json.decode(response.body);

      // Cek jika verifikasi berhasil dan menerima token
      if (response.statusCode == 200 && data['token'] != null) {
        final token = data['token'];

        // Redirect ke MainScreen setelah berhasil verifikasi
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              token: token, // Mengirim token ke MainScreen
            ),
          ),
        );
      } else {
        showMessage(data['message'] ?? 'Verifikasi OTP gagal');
      }
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resendOTP() async {
    setState(() {
      isResending = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': widget.phone,
        }),
      );

      if (response.statusCode == 200) {
        showMessage('OTP baru telah dikirim ke WhatsApp Anda', isError: false);
      } else {
        final error = json.decode(response.body);
        showMessage(error['message'] ?? 'Gagal mengirim ulang OTP');
      }
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi OTP',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFFC107),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan Kode OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kode OTP telah dikirim ke WhatsApp ${widget.phone}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.yellow.shade50,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Kode OTP",
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      hintText: "Masukkan 6 digit kode OTP",
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!isLoading) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.yellow.shade700,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.shade600.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: verifyOTP,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Verifikasi",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (!isResending) ...[
                Center(
                  child: TextButton(
                    onPressed: resendOTP,
                    child: const Text(
                      "Kirim Ulang OTP",
                      style: TextStyle(
                        color: Color(0xFFFFC107),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Informasi tambahan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Kode OTP akan dikirim melalui WhatsApp ke nomor ${widget.phone}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Kode OTP berlaku selama 5 menit',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Pastikan aplikasi WhatsApp Anda aktif',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
