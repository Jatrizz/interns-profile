import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

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
    final isMobile = Responsive.isMobile(context);

    final saveBtn = ElevatedButton(
      onPressed: isSaving ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : const Text('Save Changes',
              style: TextStyle(fontWeight: FontWeight.w600)),
    );

    final uploadBtn = ElevatedButton(
      onPressed: onUploadResume,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Upload Resume',
          style: TextStyle(fontWeight: FontWeight.w600)),
    );

    final removeBtn = ElevatedButton(
      onPressed: onRemoveResume,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDarkMode ? const Color(0xFF4E2020) : const Color(0xFFFFEBEE),
        foregroundColor:
            isDarkMode ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Remove Resume',
          style: TextStyle(fontWeight: FontWeight.w600)),
    );

    // on mobile: stack buttons vertically, full width
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          saveBtn,
          const SizedBox(height: 10),
          uploadBtn,
          if (hasResume) ...[
            const SizedBox(height: 10),
            removeBtn,
          ],
        ],
      );
    }

    // desktop: keep row layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        saveBtn,
        const SizedBox(width: 12),
        uploadBtn,
        if (hasResume) ...[
          const SizedBox(width: 12),
          removeBtn,
        ],
      ],
    );
  }
}
