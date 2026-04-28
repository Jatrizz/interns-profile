import 'package:flutter/material.dart';
import '../widgets/Intern-My-Profile-Widgets/intern_profile_image_section.dart';
import '../widgets/Intern-My-Profile-Widgets/intern_profile_resume_preview.dart';

class InternProfileBody extends StatelessWidget {
  final dynamic intern;
  final bool isDarkMode;
  final VoidCallback onBack;

  const InternProfileBody({
    super.key,
    required this.intern,
    required this.isDarkMode,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 6),
                Text(
                  "Back",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InternProfileImageSection(
                      isDarkMode: isDarkMode,
                      pickedImageFile: null,
                      profileImageUrl: intern['photo'] != null &&
                              intern['photo'].toString().isNotEmpty
                          ? "http://localhost:8080/${intern['photo'].toString().replaceFirst('/', '')}"
                          : null,
                      idNumber: intern['id_number'] ?? '',
                      isEditing: false,
                      onChangeImage: () {},
                      onRemoveImage: () {},
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child:
                              _buildField("First Name", intern['first_name']),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField("Last Name", intern['last_name']),
                        ),
                      ],
                    ),
                    _buildField("Program", intern['program']),
                    _buildField("School", intern['school']),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField("Email", intern['email']),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField("Phone", intern['phone_number']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Center(
                  child: InternProfileResumePreview(
                    isDarkMode: isDarkMode,
                    resumeFile: null,
                    resumeUrl: intern['resume'] != null &&
                            intern['resume'].toString().isNotEmpty
                        ? "http://localhost:8080/${intern['resume'].toString().replaceFirst('/', '')}"
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? const Color(0xFF9E9E9E) : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2C2C2C)
                  : const Color.fromARGB(255, 189, 189, 189),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value ?? '',
              style: TextStyle(
                color: isDarkMode
                    ? const Color.fromARGB(255, 106, 105, 105)
                    : const Color.fromARGB(255, 32, 32, 32),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
