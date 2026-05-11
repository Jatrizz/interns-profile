import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/responsive.dart';

class ContactsContact extends StatefulWidget {
  final bool isDarkMode;
  const ContactsContact({super.key, required this.isDarkMode});

  @override
  State<ContactsContact> createState() => _ContactsContactState();
}

class _ContactsContactState extends State<ContactsContact> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  bool isLoading = false;
  final String apiUrl = "http://127.0.0.1:8080/contact";

  Future<void> sendEmail() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "message": messageController.text,
        }),
      );
      setState(() => isLoading = false);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message sent successfully!")),
        );
        nameController.clear();
        emailController.clear();
        messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Widget _buildInputContainer({required Widget child, double? height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDarkMode
              ? [
                  const Color.fromARGB(255, 46, 46, 46),
                  const Color.fromARGB(255, 103, 103, 103),
                ]
              : [
                  const Color(0xFFE0E0E0),
                  const Color(0xFFCCCCCC),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final labelColor = widget.isDarkMode
        ? const Color.fromARGB(209, 255, 255, 255)
        : Colors.black54;

    // ── left info section ──
    final infoSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get in touch with us',
          style: TextStyle(
            color: textColor,
            fontSize: Responsive.value(context,
                mobile: 26.0, tablet: 32.0, desktop: 40.0),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Have questions or need help? We\'d love to hear from you.',
          style: TextStyle(color: textColor),
        ),
        const SizedBox(height: 30),
        _contactRow(Icons.location_on,
            'Our Location San Pablo City, Philippines', textColor),
        const SizedBox(height: 10),
        _contactRow(
            Icons.mark_email_read, 'Email Us support@inturn.com', textColor),
        const SizedBox(height: 10),
        _contactRow(Icons.call, 'Call us 09123456789', textColor),
        if (!isMobile) const SizedBox(height: 200),
      ],
    );

    // ── right form section ──
    final formSection = Container(
      width: isMobile ? double.infinity : 400,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: widget.isDarkMode
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.04)
                : Colors.white.withOpacity(0.9),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
        border: Border.all(
          color: widget.isDarkMode
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFEAEAEA),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name
            _buildInputContainer(
              child: TextField(
                controller: nameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  label: Text('Name', style: TextStyle(color: labelColor)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Email
            _buildInputContainer(
              child: TextField(
                controller: emailController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  label: Text('Email', style: TextStyle(color: labelColor)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Message
            _buildInputContainer(
              height: 120,
              child: TextField(
                controller: messageController,
                maxLines: 5,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  label: Text('Message', style: TextStyle(color: labelColor)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Send button
            Container(
              height: 50,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 88, 167, 231),
                    Color.fromARGB(255, 65, 39, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : sendEmail,
                  child: Center(
                    child: Text(
                      isLoading ? "Sending..." : "Send Now!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context,
            mobile: 24.0, tablet: 60.0, desktop: 130.0),
        vertical: 20,
      ),
      child: isMobile
          // mobile: stack info on top, form below
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoSection,
                const SizedBox(height: 30),
                formSection,
                const SizedBox(height: 40),
              ],
            )
          // tablet/desktop: side by side
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: infoSection),
                SizedBox(width: isTablet ? 30 : 60),
                Expanded(child: formSection),
              ],
            ),
    );
  }

  Widget _contactRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}
