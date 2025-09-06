import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();

  String? _verificationId;
  bool _loading = false;
  String? _error;
  bool _isRegistering = false;
  bool _otpSent = false;

  Future<void> _startPhoneVerification() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() => _error = 'Please enter your phone number');
      return;
    }

    if (!_isValidBangladeshiPhone(phone)) {
      setState(() => _error = 'Enter a valid BD number (e.g. 01712345678)');
      return;
    }

    if (phone.length != 11) {
      setState(() => _error = 'Phone must be exactly 11 digits');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+880' + phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) {
            if (_isRegistering) {
              await _saveUserData();
            }
            Navigator.of(context).pop();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _loading = false;
            _error = 'Verification failed: ${e.message}';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _loading = false;
            _error = null;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to verify phone number: $e';
      });
    }
  }

  Future<void> _verifyOtpAndSignIn() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() => _error = 'Please enter the OTP');
      return;
    }
    if (_verificationId == null) {
      setState(() => _error = 'Please request OTP first');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: otp);

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (_isRegistering) {
        await _saveUserData();
      }

      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        if (e.code == 'invalid-verification-code') {
          _error = 'Invalid OTP entered.';
        } else {
          _error = 'Sign-in failed: ${e.message}';
        }
      });
    }
  }

  Future<void> _saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (user == null) return;

    if (name.isEmpty) {
      setState(() {
        _error = 'Please enter your name to register.';
        _loading = false;
      });
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'name': name,
        'phone': phone,
        'isDonor': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.updateDisplayName(name);
    }
  }

  bool _isValidBangladeshiPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^01[3-9]\d{8}\$').hasMatch(phone);
  }

  void _reset() {
    setState(() {
      _otpSent = false;
      _verificationId = null;
      _error = null;
      _loading = false;
      _otpController.clear();
      if (!_isRegistering) {
        _nameController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Register' : 'Login'),
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.bloodtype, size: 60, color: Colors.red[400]),
                  const SizedBox(height: 10),
                  Text('Blood Donors',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700])),
                  const SizedBox(height: 5),
                  Text(
                    _isRegistering
                        ? 'Create account to add yourself as a donor'
                        : 'Login to access blood donor features',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            if (_isRegistering)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            if (_isRegistering) const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '01712345678',
                prefixIcon: const Icon(Icons.phone),
                prefixText: '+880 ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              enabled: !_otpSent,
            ),
            const SizedBox(height: 16),

            if (_otpSent)
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'OTP Code',
                  prefixIcon: const Icon(Icons.lock_clock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(color: Colors.red[700], fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (!_otpSent)
              ElevatedButton(
                onPressed: _startPhoneVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _isRegistering ? 'Send OTP & Register' : 'Send OTP & Login',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _verifyOtpAndSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Verify OTP',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Change Number',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                  _error = null;
                  _otpSent = false;
                  _verificationId = null;
                  _otpController.clear();
                  _nameController.clear();
                  _phoneController.clear();
                });
              },
              child: Text(
                _isRegistering
                    ? 'Already have an account? Login here'
                    : 'Don\'t have an account? Register here',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      Text('Why do I need to login?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue[700])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Authentication is required to:\n• Add yourself as a blood donor\n• Manage your donor information\n• Ensure authentic donor contacts',
                    style: TextStyle(color: Colors.blue[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
