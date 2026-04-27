import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Contact-Widgets/contacts_contact.dart';
import 'package:interfaces/widgets/Homepage-Widgets/footer.dart';
import 'package:interfaces/widgets/Homepage-Widgets/navbar.dart';

class ContactPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const ContactPage({super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void _toggle() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      appBar: NavBar(isDarkMode: isDarkMode, onToggleTheme: _toggle),
      body: ListView(
        children: [
          ContactsContact(isDarkMode: isDarkMode),
          const SizedBox(height: 220),
          Footer(isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}
