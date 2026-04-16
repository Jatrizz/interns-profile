import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:interfaces/pages/intern_dashboard.dart';

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
      } else if (!RegExp(
        r'^[^@]+@[^@]+\.[^@]+',
      ).hasMatch(_emailController.text)) {
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
        _errors['confirmpass'] = 'Please confirm your password';
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
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'school': _schoolController.text,
          'program': _programController.text,
          'email': _emailController.text,
          'phone_number': _numberController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InternDashboardPage(
              firstName: _firstNameController.text,
            ),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorData['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() => _isSubmitting = false);
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Create your Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 400,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildFieldWithError(
                            icon: Icons.person_2_outlined,
                            controller: _firstNameController,
                            label: 'First Name',
                            errorKey: 'firstName',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFieldWithError(
                            icon: Icons.person_2_outlined,
                            controller: _lastNameController,
                            label: 'Last Name',
                            errorKey: 'lastName',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFieldWithError(
                    icon: Icons.apartment_outlined,
                    controller: _schoolController,
                    label: 'School',
                    errorKey: 'school',
                  ),
                  const SizedBox(height: 10),
                  _buildFieldWithError(
                    icon: Icons.school_outlined,
                    controller: _programController,
                    label: 'Program',
                    errorKey: 'program',
                  ),
                  const SizedBox(height: 10),
                  _buildFieldWithError(
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    label: 'Email',
                    errorKey: 'email',
                  ),
                  const SizedBox(height: 10),
                  _buildFieldWithError(
                    icon: Icons.phone_callback_outlined,
                    controller: _numberController,
                    label: 'Phone Number',
                    errorKey: 'phonenum',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildFieldWithError(
                                icon: Icons.lock_outline,
                                controller: _passwordController,
                                label: 'Password',
                                errorKey: 'password',
                                obscureText: !_showPassword,
                                onChanged: _checkPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                    size: 18,
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
                              child: _buildFieldWithError(
                                icon: Icons.lock_outline,
                                controller: _confirmpassController,
                                label: 'Confirm Password',
                                errorKey: 'confirmpass',
                                obscureText: !_showConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPassword =
                                          !_showConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildCheck(
                          'At least 8 characters',
                          _passwordChecks['minLength']!,
                        ),
                        _buildCheck(
                          'At least 1 uppercase letter',
                          _passwordChecks['uppercase']!,
                        ),
                        _buildCheck(
                          'At least 1 lowercase letter',
                          _passwordChecks['lowercase']!,
                        ),
                        _buildCheck(
                          'At least 1 number',
                          _passwordChecks['number']!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By creating an account, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color.fromARGB(131, 158, 158, 158)],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, color: Colors.white) : null,
              label: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (_errors[errorKey] != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 3),
            child: Text(
              _errors[errorKey]!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCheck(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
