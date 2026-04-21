import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:interfaces/pages/login_page.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _programController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpassController = TextEditingController();

  final Map<String, String?> _errors = {};

  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final Map<String, bool> _passwordChecks = {
    'minLength': false,
    'uppercase': false,
    'lowercase': false,
    'number': false,
  };

  @override
  void initState() {
    super.initState();

    _checkPassword(_passwordController.text);

    _passwordController.addListener(() {
      _checkPassword(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _schoolController.dispose();
    _programController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    _confirmpassController.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  void _checkPassword(String password) {
    setState(() {
      _passwordChecks['minLength'] = password.length >= 8;
      _passwordChecks['uppercase'] = RegExp(r'[A-Z]').hasMatch(password);
      _passwordChecks['lowercase'] = RegExp(r'[a-z]').hasMatch(password);
      _passwordChecks['number'] = RegExp(r'\d').hasMatch(password);
    });
  }

  void _validateForm() {
    setState(() {
      _errors['firstName'] =
          _firstNameController.text.isEmpty ? 'First name is required' : null;

      _errors['lastName'] =
          _lastNameController.text.isEmpty ? 'Last name is required' : null;

      _errors['school'] =
          _schoolController.text.isEmpty ? 'School is required' : null;

      _errors['program'] =
          _programController.text.isEmpty ? 'Program is required' : null;

      if (_emailController.text.isEmpty) {
        _errors['email'] = 'Email is required';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
          .hasMatch(_emailController.text)) {
        _errors['email'] = 'Invalid email format';
      } else {
        _errors['email'] = null;
      }

      if (_numberController.text.isEmpty) {
        _errors['phonenum'] = 'Phone number is required';
      } else if (_numberController.text.length != 11) {
        _errors['phonenum'] = 'Phone number must be 11 digits';
      } else {
        _errors['phonenum'] = null;
      }

      if (_passwordController.text.isEmpty) {
        _errors['password'] = 'Password is required';
      } else if (!_isPasswordValid(_passwordController.text)) {
        _errors['password'] = 'Min 8 chars, include upper, lower & number';
      } else {
        _errors['password'] = null;
      }

      if (_confirmpassController.text.isEmpty) {
        _errors['confirmpass'] = 'Please confirm password';
      } else if (_confirmpassController.text != _passwordController.text) {
        _errors['confirmpass'] = 'Passwords do not match';
      } else {
        _errors['confirmpass'] = null;
      }
    });
  }

  Future<void> _submitForm() async {
    _validateForm();
    if (_errors.values.any((e) => e != null)) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'school': _schoolController.text.trim(),
          'program': _programController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'phone_number': _numberController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email')),
        );

        _showOtpDialog();
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? "Registration failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server connection error")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showOtpDialog() {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Email Verification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "OTP sent to ${_emailController.text}",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter OTP",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _verifyOtp(otpController.text);
              },
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyOtp(String otp) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? "Invalid OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 700,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Create your Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: Row(
                      children: [
                        Expanded(
                            child: _buildField(
                                _firstNameController, "First Name", "firstName",
                                icon: Icons.person_outline)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildField(
                                _lastNameController, "Last Name", "lastName",
                                icon: Icons.person_outline)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildField(_schoolController, "School", "school",
                      icon: Icons.apartment),
                  const SizedBox(height: 10),
                  _buildField(_programController, "Program", "program",
                      icon: Icons.school),
                  const SizedBox(height: 10),
                  _buildField(_emailController, "Email", "email",
                      icon: Icons.email_outlined),
                  const SizedBox(height: 10),
                  _buildField(
                    _numberController,
                    "Phone Number",
                    "phonenum",
                    icon: Icons.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _passwordController,
                            "Password",
                            "password",
                            icon: Icons.lock_outline,
                            obscureText: !_showPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildField(
                            _confirmpassController,
                            "Confirm Password",
                            "confirmpass",
                            icon: Icons.lock_outline,
                            obscureText: !_showConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showConfirmPassword = !_showConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCheck("At least 8 characters",
                      _passwordChecks['minLength'] ?? false),
                  _buildCheck("At least 1 uppercase",
                      _passwordChecks['uppercase'] ?? false),
                  _buildCheck("At least 1 lowercase",
                      _passwordChecks['lowercase'] ?? false),
                  _buildCheck(
                      "At least 1 number", _passwordChecks['number'] ?? false),
                  const SizedBox(height: 15),
                  Container(
                    width: 400,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Color.fromARGB(255, 2, 55, 230)],
                      ),
                    ),
                    child: InkWell(
                      onTap: _isSubmitting ? null : _submitForm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Register",
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String errorKey, {
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color.fromARGB(131, 158, 158, 158)],
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            onChanged: (v) {
              onChanged?.call(v);
            },
            inputFormatters: inputFormatters,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: icon != null ? Icon(icon, color: Colors.white) : null,
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (_errors[errorKey] != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              _errors[errorKey]!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCheck(String text, bool valid) {
    return SizedBox(
      width: 400,
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.circle_outlined,
            color: valid ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: valid ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
