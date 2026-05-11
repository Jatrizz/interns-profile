import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interfaces/pages/admin_main.dart';
import 'package:interfaces/pages/intern_main.dart';
import '../../utils/responsive.dart';

class Login extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const Login(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

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
              builder: (_) => AdminMainPage(
                firstName: data['first_name'] ?? '',
                isDarkMode: widget.isDarkMode,
                onToggleTheme: widget.onToggleTheme,
              ),
            ),
          );
        } else if (role == 'intern') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => InternMainPage(
                firstName: data['first_name'] ?? '',
                userId: data['user_id'] ?? '',
                isDarkMode: widget.isDarkMode,
                onToggleTheme: widget.onToggleTheme,
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
      if (mounted) setState(() => _isLoading = false);
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
                          Text(data['message'] ?? data['error'] ?? 'OTP Sent')),
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Forgot Password",
                      style: TextStyle(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (step == 1) ...[
                        TextField(
                          cursorColor: Colors.white,
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1)),
                            hoverColor: Colors.transparent,
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                cursorColor: Colors.white,
                                controller: otpController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: "OTP",
                                  labelStyle: TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 1)),
                                  hoverColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 22, horizontal: 25),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              onPressed: isSendingOTP ? null : sendOTP,
                              child: const Text("Send",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              padding: const EdgeInsets.symmetric(vertical: 22),
                            ),
                            onPressed: isVerifyingOTP ? null : verifyOTP,
                            child: const Text("Verify",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                      if (step == 2) ...[
                        TextField(
                          controller: newPassController,
                          obscureText: !showPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.password_outlined,
                                color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
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
                            prefixIcon: const Icon(Icons.password_outlined,
                                color: Colors.white),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            labelText: "Retype New Password",
                            labelStyle: const TextStyle(color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  showPass
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white),
                              onPressed: () =>
                                  setStateDialog(() => showPass = !showPass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: isResetting ? null : resetPassword,
                            child: const Text("Confirm",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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

  List<Color> get _fieldGradient => widget.isDarkMode
      ? [Colors.black, Colors.grey]
      : [const Color(0xFFE8E8E8), const Color(0xFFD0D0D0)];

  Color get _textColor => widget.isDarkMode ? Colors.white : Colors.black87;
  Color get _labelColor => widget.isDarkMode ? Colors.white70 : Colors.black54;
  Color get _iconColor => widget.isDarkMode ? Colors.white : Colors.black54;
  Color get _cursorColor => widget.isDarkMode ? Colors.white : Colors.black87;
  Color get _focusedBorderColor =>
      widget.isDarkMode ? Colors.white : Colors.black54;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    // ── form fields ──────────────────────────────────────────────────────
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome to InTurn',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textColor,
            fontSize: isMobile ? 28 : 40,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Manage your interns, track hours, and monitor attendance with ease.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textColor, fontSize: isMobile ? 13 : 15),
          ),
        ),
        const SizedBox(height: 20),

        // Email
        Container(
          width: isMobile ? double.infinity : 400,
          margin: isMobile ? const EdgeInsets.symmetric(horizontal: 24) : null,
          decoration:
              BoxDecoration(gradient: LinearGradient(colors: _fieldGradient)),
          child: TextFormField(
            cursorColor: _cursorColor,
            controller: _emailController,
            style: TextStyle(color: _textColor),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _focusedBorderColor)),
              prefixIcon: Icon(Icons.email_outlined, color: _iconColor),
              label: Text('Email', style: TextStyle(color: _labelColor)),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_emailError != null)
          Container(
            width: isMobile ? double.infinity : 400,
            margin:
                isMobile ? const EdgeInsets.symmetric(horizontal: 24) : null,
            padding: const EdgeInsets.only(top: 5),
            child: Text(_emailError!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 10),

        // Password
        Container(
          width: isMobile ? double.infinity : 400,
          margin: isMobile ? const EdgeInsets.symmetric(horizontal: 24) : null,
          decoration:
              BoxDecoration(gradient: LinearGradient(colors: _fieldGradient)),
          child: TextFormField(
            cursorColor: _cursorColor,
            controller: _passwordController,
            obscureText: !_showPassword,
            style: TextStyle(color: _textColor),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _focusedBorderColor)),
              prefixIcon: Icon(Icons.lock_outline, color: _iconColor),
              label: Text('Password', style: TextStyle(color: _labelColor)),
              suffixIcon: IconButton(
                icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: _iconColor),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_passwordError != null)
          Container(
            width: isMobile ? double.infinity : 400,
            margin:
                isMobile ? const EdgeInsets.symmetric(horizontal: 24) : null,
            padding: const EdgeInsets.only(top: 5),
            child: Text(_passwordError!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),

        // Forgot password
        Container(
          width: isMobile ? double.infinity : 420,
          margin: isMobile ? const EdgeInsets.symmetric(horizontal: 16) : null,
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            child: Text(
              "Forgot Password?",
              style:
                  TextStyle(color: _textColor.withOpacity(0.5), fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Login button
        Container(
          width: isMobile ? double.infinity : 400,
          margin: isMobile ? const EdgeInsets.symmetric(horizontal: 24) : null,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Color.fromARGB(255, 2, 55, 230)],
            ),
            borderRadius: BorderRadius.circular(0),
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
        const SizedBox(height: 30),
      ],
    );

    // ── logo ─────────────────────────────────────────────────────────────
    final logo = SizedBox(
      height: isMobile ? 220 : 700,
      child: widget.isDarkMode
          ? Image.asset('assets/images/logo_dark.png', fit: BoxFit.contain)
          : Image.asset('assets/images/logo_light.png', fit: BoxFit.contain),
    );

    // Mobile: logo on top, form below
    // Desktop: logo left, form right
    return isMobile
        ? Column(children: [logo, form])
        : Row(
            children: [
              Expanded(child: logo),
              Expanded(child: form),
            ],
          );
  }
}
