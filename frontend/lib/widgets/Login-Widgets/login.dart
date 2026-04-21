import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:interfaces/pages/admin_main.dart';
import 'package:interfaces/pages/register_page.dart';
import 'package:interfaces/pages/intern_main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _showPassword = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  bool _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _emailError = "Email is required";
      isValid = false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _emailError = "Enter a valid email";
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = "Password is required";
      isValid = false;
    } else if (password.length < 8) {
      _passwordError = "Minimum 8 characters";
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _login() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final role = data['role'];

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdminMainPage(firstName: data['first_name'] ?? ''),
            ),
          );
        } else if (role == 'intern') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => InternMainPage(
                firstName: data['first_name'] ?? '',
                userId: data['user_id'] ?? '',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final otpController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    int step = 1;

    bool isSendingOTP = false;
    bool isVerifyingOTP = false;
    bool isResetting = false;

    bool showPass = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> sendOTP() async {
              final email = emailController.text.trim();

              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email is required")),
                );
                return;
              }

              setStateDialog(() => isSendingOTP = true);

              try {
                final response = await http.post(
                  Uri.parse('http://localhost:8080/forgot-password/send-otp'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'email': email}),
                );

                final data = jsonDecode(response.body);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(data['message'] ?? data['error'] ?? 'OTP Sent'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Network error: $e")),
                );
              }

              setStateDialog(() => isSendingOTP = false);
            }

            Future<void> verifyOTP() async {
              final email = emailController.text.trim();
              final otp = otpController.text.trim();

              if (email.isEmpty || otp.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email and OTP are required")),
                );
                return;
              }

              setStateDialog(() => isVerifyingOTP = true);

              try {
                final response = await http.post(
                  Uri.parse('http://localhost:8080/forgot-password/verify-otp'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'email': email, 'otp': otp}),
                );

                final data = jsonDecode(response.body);

                if (response.statusCode == 200) {
                  setStateDialog(() => step = 2);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['message'] ?? 'OTP Verified')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['error'] ?? 'Invalid OTP')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Network error: $e")),
                );
              }

              setStateDialog(() => isVerifyingOTP = false);
            }

            Future<void> resetPassword() async {
              final email = emailController.text.trim();
              final pass = newPassController.text.trim();
              final confirm = confirmPassController.text.trim();

              if (pass.isEmpty || confirm.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter new password")),
                );
                return;
              }

              if (pass.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Password must be at least 8 characters")),
                );
                return;
              }

              if (pass != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Passwords do not match")),
                );
                return;
              }

              setStateDialog(() => isResetting = true);

              try {
                final response = await http.post(
                  Uri.parse('http://localhost:8080/forgot-password/reset'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'email': email, 'password': pass}),
                );

                final data = jsonDecode(response.body);

                if (response.statusCode == 200) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                        content: Text(
                            data['message'] ?? 'Password reset successful')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['error'] ?? 'Reset failed')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Network error: $e")),
                );
              }

              setStateDialog(() => isResetting = false);
            }

            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 32, 32, 32),
              title: const Text(
                "Forgot Password",
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (step == 1) ...[
                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: otpController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: "OTP",
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: isSendingOTP ? null : sendOTP,
                              child: const Text("Send"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isVerifyingOTP ? null : verifyOTP,
                            child: const Text("Verify"),
                          ),
                        ),
                      ],
                      if (step == 2) ...[
                        TextField(
                          controller: newPassController,
                          obscureText: !showPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "New Password",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: confirmPassController,
                          obscureText: !showPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Retype New Password",
                            labelStyle: const TextStyle(color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  showPass = !showPass;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isResetting ? null : resetPassword,
                            child: const Text("Confirm"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 700,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Internshit',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Container(
                width: 400,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey],
                  ),
                ),
                child: TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                    label: Text('Email', style: TextStyle(color: Colors.white)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_emailError != null)
                SizedBox(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      _emailError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                width: 400,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey],
                  ),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password_outlined,
                        color: Colors.white),
                    label: const Text('Password',
                        style: TextStyle(color: Colors.white)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_passwordError != null)
                SizedBox(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      _passwordError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text("Forgot Password",
                    style: TextStyle(color: Colors.white70)),
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
                  onTap: _isLoading ? null : _login,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
