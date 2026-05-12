import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/responsive.dart';

class InternProfileResumePreview extends StatelessWidget {
  final bool isDarkMode;
  final PlatformFile? resumeFile;
  final String? resumeUrl;

  const InternProfileResumePreview({
    super.key,
    required this.isDarkMode,
    required this.resumeFile,
    required this.resumeUrl,
  });

  bool get _hasResume =>
      resumeFile != null || (resumeUrl != null && resumeUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: isMobile ? double.infinity : 380,
      constraints: BoxConstraints(
        minHeight: isMobile ? 200 : 400,
        maxHeight: isMobile ? 300 : 620,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (resumeFile != null && resumeFile!.bytes != null)
              Positioned.fill(
                child: Image.memory(
                  resumeFile!.bytes!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _emptyResume(),
                ),
              )
            else if (resumeUrl != null && resumeUrl!.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  resumeUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _emptyResume(),
                ),
              )
            else
              _emptyResume(),
            if (_hasResume)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _showFullResume(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.open_in_full,
                        size: 18, color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyResume() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No resume uploaded',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showFullResume(BuildContext context) {
    if (!_hasResume) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: resumeFile != null && resumeFile!.bytes != null
              ? Image.memory(resumeFile!.bytes!)
              : Image.network(resumeUrl!),
        ),
      ),
    );
  }
}
