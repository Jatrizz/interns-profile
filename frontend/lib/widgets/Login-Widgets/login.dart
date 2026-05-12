import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../utils/responsive.dart';
import '../../utils/session_storage.dart';

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
        final role = data['role'] ?? '';
        final firstName = data['first_name'] ?? '';
        final userId = data['user_id']?.toString() ?? '';

        // Save to sessionStorage (per-tab) so tabs don't overwrite each other.
        saveSession(role: role, firstName: firstName, userId: userId);

        if (!mounted) return;

        if (role == 'admin') {
          context.go('/admin/dashboard');
        } else if (role == 'intern') {
          context.go('/intern/dashboard');
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

    final bool dark = widget.isDarkMode;

    final Color dialogBg =
        dark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final Color cardBg = dark ? const Color(0xFF2A2A2A) : Colors.white;
    final Color textCol = dark ? Colors.white : Colors.black87;
    final Color labelCol = dark ? Colors.white70 : Colors.black54;
    final Color iconCol = dark ? Colors.white54 : Colors.black45;
    final Color borderEn = dark ? Colors.white24 : Colors.black26;
    final Color borderFo = dark ? Colors.white : Colors.black54;

    const Gradient blueGrad = LinearGradient(
      colors: [Colors.blue, Color.fromARGB(255, 2, 55, 230)],
    );

    InputDecoration fieldDecor(String label,
            {IconData? prefix, Widget? suffix}) =>
        InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelCol, fontSize: 13),
          prefixIcon:
              prefix != null ? Icon(prefix, color: iconCol, size: 20) : null,
          suffixIcon: suffix,
          filled: true,
          fillColor: cardBg,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderEn),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderFo, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        );

    Widget gradientButton({
      required String label,
      required VoidCallback? onPressed,
      bool fullWidth = true,
      EdgeInsets padding = const EdgeInsets.symmetric(vertical: 14),
    }) {
      return Container(
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: onPressed != null ? blueGrad : null,
          color: onPressed == null ? Colors.grey : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
          ),
        ),
      );
    }

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
                  Uri.parse(
                      'http://localhost:8080/forgot-password/send-otp'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'email': email}),
                );
                final data = jsonDecode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          data['message'] ?? data['error'] ?? 'OTP Sent')),
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
                  const SnackBar(
                      content: Text("Email and OTP are required")),
                );
                return;
              }
              setStateDialog(() => isVerifyingOTP = true);
              try {
                final response = await http.post(
                  Uri.parse(
                      'http://localhost:8080/forgot-password/verify-otp'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'email': email, 'otp': otp}),
                );
                final data = jsonDecode(response.body);
                if (response.statusCode == 200) {
                  setStateDialog(() => step = 2);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(data['message'] ?? 'OTP Verified')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(data['error'] ?? 'Invalid OTP')),
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
                      content:
                          Text("Password must be at least 8 characters")),
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
                        content: Text(data['message'] ??
                            'Password reset successful')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(data['error'] ?? 'Reset failed')),
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
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: blueGrad,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lock_reset,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Forgot Password",
                            style: TextStyle(
                                color: textCol,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text(
                          step == 1
                              ? "Enter your email and OTP to verify"
                              : "Set your new password",
                          style: TextStyle(
                              color: labelCol,
                              fontSize: 11,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: iconCol, size: 20),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 18,
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _StepDot(
                              active: true, label: "1", done: step == 2),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: step == 2 ? Colors.blue : borderEn,
                            ),
                          ),
                          _StepDot(
                              active: step == 2, label: "2", done: false),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (step == 1) ...[
                        TextField(
                          cursorColor: borderFo,
                          controller: emailController,
                          style: TextStyle(color: textCol, fontSize: 14),
                          decoration: fieldDecor("Email",
                                  prefix: Icons.email_outlined)
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                cursorColor: borderFo,
                                controller: otpController,
                                style: TextStyle(
                                    color: textCol, fontSize: 14),
                                keyboardType: TextInputType.number,
                                decoration: fieldDecor("OTP Code",
                                    prefix: Icons.pin_outlined),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                gradient: isSendingOTP ? null : blueGrad,
                                color:
                                    isSendingOTP ? Colors.grey : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: isSendingOTP ? null : sendOTP,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: isSendingOTP
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text("Send",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        gradientButton(
                          label: isVerifyingOTP
                              ? "Verifying…"
                              : "Verify OTP",
                          onPressed: isVerifyingOTP ? null : verifyOTP,
                        ),
                      ],
                      if (step == 2) ...[
                        TextField(
                          controller: newPassController,
                          obscureText: !showPass,
                          cursorColor: borderFo,
                          style: TextStyle(color: textCol, fontSize: 14),
                          decoration: fieldDecor("New Password",
                              prefix: Icons.lock_outline),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: confirmPassController,
                          obscureText: !showPass,
                          cursorColor: borderFo,
                          style: TextStyle(color: textCol, fontSize: 14),
                          decoration: fieldDecor(
                            "Confirm Password",
                            prefix: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                showPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: iconCol,
                                size: 20,
                              ),
                              onPressed: () => setStateDialog(
                                  () => showPass = !showPass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        gradientButton(
                          label: isResetting ? "Resetting…" : "Confirm",
                          onPressed: isResetting ? null : resetPassword,
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
            style: TextStyle(
                color: _textColor, fontSize: isMobile ? 13 : 15),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: isMobile ? double.infinity : 400,
          margin:
              isMobile ? const EdgeInsets.symmetric(horizontal: 24) : null,
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
        Container(
          width: isMobile ? double.infinity : 400,
          margin:
              isMobile ? const EdgeInsets.symmetric(horizontal: 24) : null,
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
                    _showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: _iconColor),
                onPressed: () =>
                    setState(() => _showPassword = !_showPassword),
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
        Container(
          width: isMobile ? double.infinity : 420,
          margin:
              isMobile ? const EdgeInsets.symmetric(horizontal: 16) : null,
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                  color: _textColor.withOpacity(0.5), fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: isMobile ? double.infinity : 400,
          margin:
              isMobile ? const EdgeInsets.symmetric(horizontal: 24) : null,
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

    final logo = SizedBox(
      height: isMobile ? 220 : 700,
      child: widget.isDarkMode
          ? Image.asset('assets/images/logo_dark.png', fit: BoxFit.contain)
          : Image.asset('assets/images/logo_light.png', fit: BoxFit.contain),
    );

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

class _StepDot extends StatelessWidget {
  final bool active;
  final bool done;
  final String label;
  const _StepDot(
      {required this.active, required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: active
            ? const LinearGradient(
                colors: [Colors.blue, Color.fromARGB(255, 2, 55, 230)])
            : null,
        color: active ? null : Colors.grey.withOpacity(0.3),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : Text(label,
                style: TextStyle(
                    color: active ? Colors.white : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
      ),
    );
  }
}