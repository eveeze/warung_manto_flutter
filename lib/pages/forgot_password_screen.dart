import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minggu_4/service/auth_service.dart';
import 'package:minggu_4/pages/reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _showMessage(String message, {bool isError = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isError ? 'Error' : 'Success',
            style: GoogleFonts.poppins(),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty) {
      _showMessage('Nomor HP tidak boleh kosong');
      return;
    }

    String formattedPhone = _phoneController.text;
    if (!formattedPhone.startsWith('+')) {
      formattedPhone = '+$formattedPhone';
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.sendForgotPasswordOTP(formattedPhone);

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyResetPasswordOTPScreen(
              phone: formattedPhone,
            ),
          ),
        );
      } else {
        _showMessage('Gagal mengirim OTP. Silakan coba lagi.');
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF093C25),
      appBar: AppBar(
        backgroundColor: const Color(0xFF093C25),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Lupa Password',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Masukkan nomor HP Anda untuk mereset password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Nomor Handphone',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(color: const Color(0xFF000000)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    hintText: '628188280680',
                    hintStyle:
                        GoogleFonts.poppins(color: const Color(0xFFB0A6A6)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Kirim OTP',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
