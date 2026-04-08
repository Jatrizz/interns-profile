import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Contact-Widgets/contacts_contact.dart';
import 'package:interfaces/widgets/Homepage-Widgets/footer.dart';
import 'package:interfaces/widgets/Homepage-Widgets/navbar.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: ListView(
        children: [ContactsContact(), SizedBox(height: 220), Footer()],
      ),
    );
  }
}
