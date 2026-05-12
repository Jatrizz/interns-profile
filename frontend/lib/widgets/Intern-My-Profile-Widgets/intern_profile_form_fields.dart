import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/responsive.dart';

class InternProfileFormFields extends StatelessWidget {
  final bool isDarkMode;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController programController;
  final TextEditingController schoolController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const InternProfileFormFields({
    super.key,
    required this.isDarkMode,
    required this.firstNameController,
    required this.lastNameController,
    required this.programController,
    required this.schoolController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First Name + Last Name
        isMobile
            ? Column(
                children: [
                  _buildField(
                      label: 'First Name', controller: firstNameController),
                  const SizedBox(height: 16),
                  _buildField(
                      label: 'Last Name', controller: lastNameController),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildField(
                        label: 'First Name', controller: firstNameController),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                        label: 'Last Name', controller: lastNameController),
                  ),
                ],
              ),
        const SizedBox(height: 16),
        _buildLabel('Program'),
        const SizedBox(height: 6),
        _buildField(
            label: 'Program', controller: programController, showLabel: false),
        const SizedBox(height: 16),
        _buildLabel('School'),
        const SizedBox(height: 6),
        _buildField(
            label: 'School', controller: schoolController, showLabel: false),
        const SizedBox(height: 16),

        // Email + Phone
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Email'),
                  const SizedBox(height: 6),
                  _buildField(
                    label: 'Email',
                    controller: emailController,
                    showLabel: false,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  const SizedBox(height: 6),
                  _buildField(
                    label: 'Phone Number',
                    controller: phoneController,
                    showLabel: false,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Email'),
                        const SizedBox(height: 6),
                        _buildField(
                          label: 'Email',
                          controller: emailController,
                          showLabel: false,
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Phone Number'),
                        const SizedBox(height: 6),
                        _buildField(
                          label: 'Phone Number',
                          controller: phoneController,
                          showLabel: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool showLabel = true,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          _buildLabel(label),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? (isDarkMode
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFEEEEEE))
                : (isDarkMode
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFF5F5F5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}
