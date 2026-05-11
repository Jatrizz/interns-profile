import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Contact-Widgets/contacts_contact.dart';
import 'package:interfaces/widgets/Homepage-Widgets/footer.dart';
import 'package:interfaces/widgets/Homepage-Widgets/navbar.dart';

class ContactPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const ContactPage(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late bool isDarkMode;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void _toggle() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      appBar: NavBar(
          isDarkMode: isDarkMode,
          onToggleTheme: _toggle,
          activePage: 'Contact',
          scaffoldKey: _scaffoldKey),
      endDrawer: NavDrawer(
          isDarkMode: isDarkMode,
          onToggleTheme: _toggle,
          activePage: 'Contact'),
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
