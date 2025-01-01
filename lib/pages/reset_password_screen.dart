import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minggu_4/service/auth_service.dart';
import 'package:minggu_4/pages/home_screen.dart';

class VerifyResetPasswordOTPScreen extends StatefulWidget {
  final String phone;

  const VerifyResetPasswordOTPScreen({super.key, required this.phone});

  @override
  _VerifyResetPasswordOTPScreenState createState() =>
      _VerifyResetPasswordOTPScreenState();
}

class _VerifyResetPasswordOTPScreenState
    extends State<VerifyResetPasswordOTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isOTPVerified = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      _showSnackBar('OTP tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.verifyResetPasswordOTP(
        phone: widget.phone,
        otp: _otpController.text,
      );

      if (success) {
        setState(() {
          _isOTPVerified = true;
        });
        _showSnackBar('OTP berhasil diverifikasi', isError: false);
      } else {
        _showSnackBar('OTP tidak valid. Silakan coba lagi.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Password tidak boleh kosong');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Password dan konfirmasi password tidak cocok');
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showSnackBar('Password minimal 8 karakter');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.resetPassword(
        phone: widget.phone,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (success) {
        _showSnackBar('Password berhasil direset', isError: false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        _showSnackBar('Gagal mereset password. Silakan coba lagi.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    bool obscureText = false,
    bool? isObscured,
    VoidCallback? onObscureToggle,
    TextInputType? keyboardType, // Add this line
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscured ?? obscureText,
            keyboardType: obscureText ? TextInputType.visiblePassword : null,
            style: GoogleFonts.poppins(color: const Color(0xFF000000)),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(color: const Color(0xFFB0A6A6)),
              suffixIcon: obscureText
                  ? IconButton(
                      icon: Icon(
                        isObscured ?? false
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: onObscureToggle,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
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
                  'Reset Password',
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
                  'Masukkan OTP yang telah dikirim ke nomor ${widget.phone}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // OTP TextField
              _buildTextField(
                controller: _otpController,
                hintText: 'Masukkan OTP',
                labelText: 'OTP',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // Conditionally show Verify OTP Button
              if (!_isOTPVerified) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Verifikasi OTP',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],

              // Password reset section
              if (_isOTPVerified) ...[
                const SizedBox(height: 40),
                // New Password TextField
                _buildTextField(
                  controller: _newPasswordController,
                  hintText: 'Password Baru',
                  labelText: 'Password Baru',
                  obscureText: true,
                  isObscured: _isPasswordObscured,
                  onObscureToggle: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Confirm Password TextField
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Konfirmasi Password',
                  labelText: 'Konfirmasi Password',
                  obscureText: true,
                  isObscured: _isConfirmPasswordObscured,
                  onObscureToggle: () {
                    setState(() {
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Reset Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Reset Password',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
