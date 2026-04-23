import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InternProfileImageSection extends StatelessWidget {
  final bool isDarkMode;
  final XFile? pickedImageFile;
  final String? profileImageUrl;
  final String idNumber;
  final bool isEditing;
  final VoidCallback onChangeImage;
  final VoidCallback onRemoveImage;

  const InternProfileImageSection({
    super.key,
    required this.isDarkMode,
    required this.pickedImageFile,
    required this.profileImageUrl,
    required this.idNumber,
    required this.isEditing,
    required this.onChangeImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final viewOnlyColor =
        isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFF757575);

    // Support text color is always the same regardless of editing state
    final supportTextColor =
        isDarkMode ? Colors.grey[500]! : Colors.grey[600]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(),
            const SizedBox(width: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: isEditing ? onChangeImage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFE0E0E0),
                        disabledBackgroundColor: isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFE0E0E0),
                        foregroundColor: isEditing
                            ? (isDarkMode ? Colors.white : Colors.black)
                            : viewOnlyColor,
                        disabledForegroundColor: viewOnlyColor,
                        elevation: isEditing ? 2 : 0,
                        shadowColor: Colors.transparent,
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
                      onPressed: isEditing ? onRemoveImage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFE0E0E0),
                        disabledBackgroundColor: isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFE0E0E0),
                        foregroundColor: isEditing
                            ? (isDarkMode ? Colors.white : Colors.black)
                            : viewOnlyColor,
                        disabledForegroundColor: viewOnlyColor,
                        elevation: isEditing ? 2 : 0,
                        shadowColor: Colors.transparent,
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
                // Always the same color — no isEditing dependency
                Text(
                  'Support JPEG and PNG formats under 2mb.',
                  style: TextStyle(
                    color: supportTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ID NO and Divider are completely independent of isEditing
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

  Widget _buildAvatar() {
    if (pickedImageFile != null) {
      return FutureBuilder<ImageProvider>(
        future: _loadPickedImage(),
        builder: (context, snapshot) {
          return CircleAvatar(
            key: ValueKey(pickedImageFile!.name),
            radius: 70,
            backgroundColor: isDarkMode
                ? const Color(0xFF3A3A3A)
                : const Color(0xFFDDDDDD),
            backgroundImage: snapshot.data,
            child: snapshot.data == null
                ? const CircularProgressIndicator()
                : null,
          );
        },
      );
    }

    return CircleAvatar(
      key: ValueKey(profileImageUrl ?? ''),
      radius: 70,
      backgroundColor:
          isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFDDDDDD),
      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
          ? NetworkImage(profileImageUrl!)
          : null,
      child: profileImageUrl == null || profileImageUrl!.isEmpty
          ? Icon(
              Icons.person,
              size: 60,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            )
          : null,
    );
  }

  Future<ImageProvider> _loadPickedImage() async {
    final bytes = await pickedImageFile!.readAsBytes();
    return MemoryImage(bytes);
  }
}