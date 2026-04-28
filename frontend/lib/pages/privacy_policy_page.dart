import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const PrivacyPolicyPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      body: ListView(
        children: [
          _PolicyContent(isDarkMode: isDarkMode, isPrivacy: true),
        ],
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const TermsOfServicePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      body: ListView(
        children: [
          _PolicyContent(isDarkMode: isDarkMode, isPrivacy: false),
        ],
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  final bool isDarkMode;
  final bool isPrivacy;
  const _PolicyContent({required this.isDarkMode, required this.isPrivacy});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final cardColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final dividerColor = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);

    final sections = isPrivacy ? _privacySections : _termsSections;
    final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';
    final subtitle = 'Effective Date: April 24, 2026';
    final description = isPrivacy
        ? 'The Intern Management System is committed to protecting the privacy and personal data of its users, including interns, administrators, and affiliated organizations.'
        : 'These Terms of Service govern the access to and use of the Intern Management System. By accessing or using the System, users agree to be bound by these terms.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, size: 14, color: subtitleColor),
                const SizedBox(width: 4),
                Text(
                  'Back',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 65, 142, 204),
                            Color.fromARGB(255, 0, 4, 250),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPrivacy ? 'Privacy' : 'Legal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 500,
                      child: Text(
                        description,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Sections
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dividerColor),
            ),
            child: Column(
              children: sections.asMap().entries.map((entry) {
                final index = entry.key;
                final section = entry.value;
                final isLast = index == sections.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Number badge
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 65, 142, 204),
                                  Color.fromARGB(255, 0, 4, 250),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  section['title']!,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  section['body']!,
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 14,
                                    height: 1.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) Divider(height: 1, color: dividerColor),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),

          // Footer note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.mail_outline, color: subtitleColor, size: 18),
                const SizedBox(width: 12),
                Text(
                  'For questions or concerns, contact us at ',
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
                const Text(
                  'email@company.com',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  static const List<Map<String, String>> _privacySections = [
    {
      'title': 'Information We Collect',
      'body':
          'We collect personal information necessary for the effective management of internship programs. This includes full name, email address, phone number, academic affiliation, course or program details, and assigned identification numbers. We also collect system-generated data such as login timestamps, attendance records, activity logs, and device or browser information. Users may also upload documents, images, or other content relevant to their internship.',
    },
    {
      'title': 'How We Use Your Information',
      'body':
          'The information collected is used primarily to facilitate the administration of internship-related processes. This includes maintaining user profiles, tracking attendance and performance, generating reports and analytics, ensuring secure authentication, and improving overall system performance. We process data only to the extent necessary to fulfill these purposes and in accordance with applicable laws and regulations.',
    },
    {
      'title': 'Information Sharing',
      'body':
          'We do not sell, rent, or trade personal information to third parties. However, data may be shared with authorized personnel such as system administrators, supervisors, or affiliated educational institutions when required for legitimate operational purposes. We may also disclose information when required to comply with legal obligations, enforce policies, or protect the rights, safety, and security of users and the organization.',
    },
    {
      'title': 'Data Security',
      'body':
          'We implement reasonable administrative, technical, and organizational safeguards to protect user data against unauthorized access, disclosure, alteration, or destruction. These measures include secure communication protocols, controlled access to data, and authentication mechanisms. Despite these efforts, no system can guarantee absolute security, and users acknowledge this inherent risk.',
    },
    {
      'title': 'Data Retention & User Rights',
      'body':
          'Personal data is retained only for as long as necessary to fulfill the purposes outlined in this policy or to comply with legal and regulatory requirements. Upon request and subject to applicable laws, users may seek access to their personal data, request corrections, or request deletion where appropriate.',
    },
    {
      'title': 'Cookies & Technologies',
      'body':
          'The System may use cookies or similar technologies to manage user sessions, facilitate authentication, and improve user experience. These technologies do not collect unnecessary personal information and are used strictly for operational purposes.',
    },
    {
      'title': 'Policy Updates',
      'body':
          'We reserve the right to update or modify this Privacy Policy at any time. Any changes will be reflected by updating the effective date above, and continued use of the System constitutes acceptance of such changes.',
    },
  ];

  static const List<Map<String, String>> _termsSections = [
    {
      'title': 'Account Responsibilities',
      'body':
          'Users are required to provide accurate, complete, and up-to-date information when creating and maintaining their accounts. Each user is responsible for safeguarding their login credentials and for all activities that occur under their account. Any unauthorized use or suspected breach of security must be reported immediately to the appropriate system administrator.',
    },
    {
      'title': 'Acceptable Use',
      'body':
          'The System is intended solely for legitimate internship management purposes, including tracking intern information, attendance, performance, and related administrative functions. Users agree not to misuse the System by attempting to gain unauthorized access, disrupting system operations, introducing malicious code, or engaging in any unlawful or prohibited activities.',
    },
    {
      'title': 'Data Accuracy',
      'body':
          'Users are responsible for the accuracy and integrity of the data they provide or upload to the System. Organizations and administrators are likewise responsible for ensuring that their use of the data complies with applicable data protection and privacy laws. The System provider does not assume responsibility for incorrect or improperly managed data entered by users.',
    },
    {
      'title': 'Service Availability',
      'body':
          'While we strive to ensure that the System remains accessible and operates efficiently, we do not guarantee uninterrupted availability or error-free performance. Maintenance, updates, or unforeseen technical issues may result in temporary service disruptions.',
    },
    {
      'title': 'Intellectual Property',
      'body':
          'All intellectual property rights related to the System, including its design, structure, and underlying code, remain the property of the System provider or its licensors. Users retain ownership of any content or data they upload, subject to the rights granted for system operation and administration.',
    },
    {
      'title': 'Termination',
      'body':
          'We reserve the right to suspend or terminate user access to the System at our discretion, particularly in cases of violation of these Terms, suspected fraudulent activity, or actions that may compromise the integrity or security of the System.',
    },
    {
      'title': 'Limitation of Liability',
      'body':
          'To the fullest extent permitted by law, the System provider shall not be held liable for any direct, indirect, incidental, or consequential damages arising from the use or inability to use the System, including but not limited to data loss, unauthorized access, or service interruptions beyond our reasonable control.',
    },
    {
      'title': 'Changes to Terms',
      'body':
          'These Terms of Service may be updated or revised at any time without prior notice. Continued use of the System after any modifications constitutes acceptance of the updated terms. These terms shall be governed by and construed in accordance with the laws of the Philippines.',
    },
  ];
}