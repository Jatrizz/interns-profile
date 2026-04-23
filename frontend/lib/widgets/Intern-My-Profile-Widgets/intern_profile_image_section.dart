import 'package:flutter/material.dart';
import 'dart:io';

class InternProfileImageSection extends StatelessWidget {
  final bool isDarkMode;
  final File? profileImage;
  final String? profileImageUrl;
  final String idNumber;
  final VoidCallback onChangeImage;
  final VoidCallback onRemoveImage;

  const InternProfileImageSection({
    super.key,
    required this.isDarkMode,
    required this.profileImage,
    required this.profileImageUrl,
    required this.idNumber,
    required this.onChangeImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            CircleAvatar(
              key: ValueKey(profileImageUrl ?? ''),
              radius: 70,
              backgroundColor: isDarkMode
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFFDDDDDD),
              backgroundImage: profileImage != null
                ? FileImage(profileImage!) as ImageProvider
                : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? NetworkImage(profileImageUrl!)
                    : null),
              child: (profileImage == null &&
                      (profileImageUrl == null || profileImageUrl!.isEmpty))
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    )
                  : null,
            ),
            const SizedBox(width: 32),
            // Buttons + hint
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onChangeImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFE0E0E0),
                        foregroundColor:
                            isDarkMode ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Change Image'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onRemoveImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFE0E0E0),
                        foregroundColor:
                            isDarkMode ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Remove Image'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Support JPEG and PNG formats under 2mb.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ID Number
        Text(
          'ID NO: $idNumber',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Divider(
          color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
        ),
      ],
    );
  }
}
