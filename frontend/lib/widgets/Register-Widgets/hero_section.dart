import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  _HeroSectionState createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _programController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Map<String, String?> _errors = {};

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _schoolController.dispose();
    _programController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regex.hasMatch(password);
  }

  void _validateForm() {
    setState(() {
      _errors['firstName'] = _firstNameController.text.isEmpty
          ? 'First name is required'
          : null;
      _errors['lastName'] = _lastNameController.text.isEmpty
          ? 'Last name is required'
          : null;
      _errors['school'] = _schoolController.text.isEmpty
          ? 'School is required'
          : null;
      _errors['program'] = _programController.text.isEmpty
          ? 'Program is required'
          : null;

      if (_emailController.text.isEmpty) {
        _errors['email'] = 'Email is required';
      } else if (!RegExp(
        r'^[^@]+@[^@]+\.[^@]+',
      ).hasMatch(_emailController.text)) {
        _errors['email'] = 'Invalid email format';
      } else {
        _errors['email'] = null;
      }

      if (_passwordController.text.isEmpty) {
        _errors['password'] = 'Password is required';
      } else if (!_isPasswordValid(_passwordController.text)) {
        _errors['password'] = 'Min 8 chars, include upper, lower & number';
      } else {
        _errors['password'] = null;
      }
    });
  }

  Future<void> _registerUser() async {
    _validateForm();
    if (_errors.values.any((e) => e != null)) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost:8080/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'school': _schoolController.text.trim(),
          'program': _programController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
      } else {
        setState(() {
          if (data['field'] != null && data['message'] != null) {
            _errors[data['field']] = data['message'];
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Registration failed')),
            );
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 700,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Create your Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: 400,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildFieldWithError(
                            controller: _firstNameController,
                            label: 'First Name',
                            errorKey: 'firstName',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildFieldWithError(
                            controller: _lastNameController,
                            label: 'Last Name',
                            errorKey: 'lastName',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildFieldWithError(
                    controller: _schoolController,
                    label: 'School',
                    errorKey: 'school',
                  ),
                  SizedBox(height: 10),
                  _buildFieldWithError(
                    controller: _programController,
                    label: 'Program',
                    errorKey: 'program',
                  ),
                  SizedBox(height: 10),
                  _buildFieldWithError(
                    controller: _emailController,
                    label: 'Email',
                    errorKey: 'email',
                  ),
                  SizedBox(height: 10),
                  _buildFieldWithError(
                    controller: _passwordController,
                    label: 'Password',
                    errorKey: 'password',
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 400,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Color.fromARGB(255, 2, 55, 230)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _registerUser,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Register',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        children: [
                          TextSpan(
                            text: 'By creating an account, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
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

  Widget _buildFieldWithError({
    required TextEditingController controller,
    required String label,
    required String errorKey,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              label: Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_errors[errorKey] != null)
          Padding(
            padding: EdgeInsets.only(left: 8, top: 3),
            child: Text(
              _errors[errorKey]!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
