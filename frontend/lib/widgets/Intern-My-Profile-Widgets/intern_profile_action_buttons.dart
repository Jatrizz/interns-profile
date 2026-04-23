import 'package:flutter/material.dart';

class InternProfileActionButtons extends StatelessWidget {
  final bool isDarkMode;
  final bool isSaving;
  final bool hasResume;
  final VoidCallback onSave;
  final VoidCallback onUploadResume;
  final VoidCallback onRemoveResume;

  const InternProfileActionButtons({
    super.key,
    required this.isDarkMode,
    required this.isSaving,
    required this.hasResume,
    required this.onSave,
    required this.onUploadResume,
    required this.onRemoveResume,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Save Changes
        ElevatedButton(
          onPressed: isSaving ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BCD4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
        const SizedBox(width: 12),

        // Upload Resume
        ElevatedButton(
          onPressed: onUploadResume,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Upload Resume',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Remove Resume — only shown if there's an existing resume
        if (hasResume) ...[
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onRemoveResume,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode
                  ? const Color(0xFF4E2020)
                  : const Color(0xFFFFEBEE),
              foregroundColor:
                  isDarkMode ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Remove Resume',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }
}