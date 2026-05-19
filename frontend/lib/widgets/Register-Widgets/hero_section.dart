import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:interfaces/pages/login_page.dart';
import 'package:flutter/gestures.dart';
import 'package:interfaces/pages/privacy_policy_page.dart';
import '../../utils/responsive.dart';

class HeroSection extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const HeroSection(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

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

  final _passwordFocusNode = FocusNode();
  bool _passwordFocused = true;

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

  bool get _dark => widget.isDarkMode;
  Color get _textColor => _dark ? Colors.white : Colors.black87;
  Color get _labelColor => _dark ? Colors.white70 : Colors.black54;
  Color get _iconColor => _dark ? Colors.white : Colors.black54;
  Color get _cursorColor => _dark ? Colors.white : Colors.black87;
  Color get _focusedBorderColor => _dark ? Colors.white : Colors.black54;
  List<Color> get _fieldGradient => _dark
      ? [Colors.black, const Color.fromARGB(131, 158, 158, 158)]
      : [const Color(0xFFE8E8E8), const Color(0xFFD0D0D0)];

  @override
  void initState() {
    super.initState();
    _checkPassword(_passwordController.text);
    _passwordController
        .addListener(() => _checkPassword(_passwordController.text));
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() => _passwordFocused = true);
      }
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
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String password) =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password);

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
      } else if (!_numberController.text.startsWith('09')) {
        _errors['phonenum'] = 'Must start with 09';
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
      String errorMsg = 'Registration failed';
      try {
        final error = jsonDecode(response.body);
        errorMsg = error['error'] ?? error.toString();
      } catch (_) {
        errorMsg = response.body.isNotEmpty ? response.body : 'Registration failed';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
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
    final controllers = List.generate(6, (_) => TextEditingController());
    final focusNodes = List.generate(6, (_) => FocusNode());
    bool isVerifying = false;
    String? errorMsg;

    String getOtp() => controllers.map((c) => c.text).join();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final dark = widget.isDarkMode;
          final bg = dark ? const Color(0xFF1E1E1E) : Colors.white;
          final cardBg =
              dark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F6FA);
          final textColor = dark ? Colors.white : Colors.black87;
          final subColor = dark ? Colors.white54 : Colors.black45;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.5 : 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Color.fromARGB(255, 2, 55, 230)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.mark_email_read_outlined,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Verify your email',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'We sent a 6-digit code to',
                    style: TextStyle(color: subColor, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _emailController.text.trim(),
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 40,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: controllers[i].text.isNotEmpty
                                ? const Color(0xFF4F46E5)
                                : (dark ? Colors.white12 : Colors.black12),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: controllers[i],
                          focusNode: focusNodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          cursorColor: const Color(0xFF4F46E5),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            setDialogState(() => errorMsg = null);
                            if (val.isNotEmpty && i < 5) {
                              focusNodes[i + 1].requestFocus();
                            } else if (val.isEmpty && i > 0) {
                              focusNodes[i - 1].requestFocus();
                            }
                            setDialogState(() {});
                          },
                        ),
                      );
                    }),
                  ),

                  // Error message
                  if (errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 14),
                        const SizedBox(width: 4),
                        Text(errorMsg!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Color.fromARGB(255, 2, 55, 230)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isVerifying
                            ? null
                            : () async {
                                final otp = getOtp();
                                if (otp.length < 6) {
                                  setDialogState(() =>
                                      errorMsg = 'Please enter all 6 digits');
                                  return;
                                }
                                setDialogState(() => isVerifying = true);
                                await _verifyOtp(otp, setDialogState, (msg) {
                                  setDialogState(() => errorMsg = msg);
                                });
                                setDialogState(() => isVerifying = false);
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: isVerifying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Verify Email',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _verifyOtp(
    String otp,
    StateSetter setDialogState,
    void Function(String) onError,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim(), 'otp': otp}),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(
                isDarkMode: widget.isDarkMode,
                onToggleTheme: widget.onToggleTheme),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        onError(error['error'] ?? 'Invalid OTP');
      }
    } catch (e) {
      onError('Verification failed. Check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final fieldWidth = isMobile ? double.infinity : 400.0;
    final hPad = isMobile ? 24.0 : 0.0;

    final form = SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Create your Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: isMobile ? 26 : 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // First + Last name
              SizedBox(
                width: fieldWidth,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        _firstNameController,
                        "First Name",
                        "firstName",
                        icon: Icons.person_outline,
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildField(
                        _lastNameController,
                        "Last Name",
                        "lastName",
                        icon: Icons.person_outline,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // School with hint
              _buildField(
                _schoolController,
                "School",
                "school",
                icon: Icons.apartment,
                hintText: 'e.g. Laguna State Polytechnic University',
              ),
              const SizedBox(height: 10),

              // Program with hint
              _buildField(
                _programController,
                "Program",
                "program",
                icon: Icons.school,
                hintText:
                    'e.g. BS in Computer Science, BS in Information Systems',
              ),
              const SizedBox(height: 10),

              _buildField(_emailController, "Email", "email",
                  icon: Icons.email_outlined),
              const SizedBox(height: 10),
              _buildField(
                _numberController,
                "Phone Number",
                "phonenum",
                icon: Icons.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (_) {
                setState(() {
                  final val = _numberController.text;
                  if (val.isEmpty) {
                    _errors['phonenum'] = null;
                  } else if (val.length >= 2 && !val.startsWith('09')) {
                    _errors['phonenum'] = 'Must start with 09';
                  } else if (val.length == 11 && !val.startsWith('09')) {
                    _errors['phonenum'] = 'Must start with 09';
                  } else if (val.length == 11 && val.startsWith('09')) {
                    _errors['phonenum'] = null;
                  } else {
                    _errors['phonenum'] = null;
                  }
                });
                }
              ),
              const SizedBox(height: 10),

              // Password + Confirm
              SizedBox(
                width: fieldWidth,
                child: isMobile
                    ? Column(
                        children: [
                          _buildField(
                            _passwordController,
                            "Password",
                            "password",
                            icon: Icons.lock_outline,
                            obscureText: !_showPassword,
                            fullWidth: true,
                            focusNode: _passwordFocusNode,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: _iconColor,
                              ),
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildField(
                            _confirmpassController,
                            "Confirm Password",
                            "confirmpass",
                            icon: Icons.lock_outline,
                            obscureText: !_showConfirmPassword,
                            fullWidth: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: _iconColor,
                              ),
                              onPressed: () => setState(() =>
                                  _showConfirmPassword = !_showConfirmPassword),
                            ),
                            onChanged: (_) {
                              setState(() {
                                if (_confirmpassController.text.isEmpty) {
                                  _errors['confirmpass'] = null;
                                } else {
                                  _errors['confirmpass'] =
                                      _confirmpassController.text !=
                                              _passwordController.text
                                          ? 'Passwords do not match'
                                          : null;
                                }
                              });
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _passwordController,
                              "Password",
                              "password",
                              icon: Icons.lock_outline,
                              obscureText: !_showPassword,
                              fullWidth: true,
                              focusNode: _passwordFocusNode,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: _iconColor,
                                ),
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
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
                              fullWidth: true,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: _iconColor,
                                ),
                                onPressed: () => setState(() =>
                                    _showConfirmPassword =
                                        !_showConfirmPassword),
                              ),
                              onChanged: (_) {
                                setState(() {
                                  _errors['confirmpass'] =
                                      _confirmpassController.text !=
                                              _passwordController.text
                                          ? 'Passwords do not match'
                                          : null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
              ),

              // Password strength
              if (_passwordFocused) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: fieldWidth,
                  child: Column(
                    children: [
                      _buildCheck("At least 8 characters",
                          _passwordChecks['minLength'] ?? false),
                      _buildCheck("At least 1 uppercase",
                          _passwordChecks['uppercase'] ?? false),
                      _buildCheck("At least 1 lowercase",
                          _passwordChecks['lowercase'] ?? false),
                      _buildCheck("At least 1 number",
                          _passwordChecks['number'] ?? false),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 15),

              // Register button
              Container(
                width: fieldWidth,
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Register",
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Terms & Privacy
              SizedBox(
                width: fieldWidth,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: _textColor, fontSize: 12),
                    children: [
                      const TextSpan(
                          text: 'By creating an account, you agree to our '),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      TermsOfServicePage(
                                    isDarkMode: widget.isDarkMode,
                                    onToggleTheme: widget.onToggleTheme,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      PrivacyPolicyPage(
                                    isDarkMode: widget.isDarkMode,
                                    onToggleTheme: widget.onToggleTheme,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );

    final logo = SizedBox(
      height: isMobile ? 200 : 700,
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

  Widget _buildField(
    TextEditingController controller,
    String label,
    String errorKey, {
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    bool fullWidth = false,
    FocusNode? focusNode,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: fullWidth ? null : 400,
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _fieldGradient),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            cursorColor: _cursorColor,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            focusNode: focusNode,
            style: TextStyle(color: _textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _focusedBorderColor),
              ),
              prefixIcon: icon != null ? Icon(icon, color: _iconColor) : null,
              labelText: label,
              labelStyle: TextStyle(color: _labelColor, fontSize: 12),
              suffixIcon: suffixIcon,
              hintText: hintText, // ✅ added
              hintStyle: TextStyle(color: _labelColor, fontSize: 11), // ✅ added
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
    return Row(
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
              color: valid ? Colors.green : Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
