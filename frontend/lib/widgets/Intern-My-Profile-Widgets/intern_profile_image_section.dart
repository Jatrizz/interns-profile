import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/responsive.dart';

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
    final isMobile = Responsive.isMobile(context);
    final viewOnlyColor =
        isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFF757575);
    final supportTextColor = isDarkMode ? Colors.grey[500]! : Colors.grey[600]!;

    final avatar = _buildAvatar(isMobile);

    final buttons = Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: isEditing ? onChangeImage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
            disabledBackgroundColor:
                isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
            foregroundColor: isEditing
                ? (isDarkMode ? Colors.white : Colors.black)
                : viewOnlyColor,
            disabledForegroundColor: viewOnlyColor,
            elevation: isEditing ? 2 : 0,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            (pickedImageFile != null ||
                    (profileImageUrl != null && profileImageUrl!.isNotEmpty))
                ? 'Change Image'
                : 'Upload Image',
          ),
        ),
        ElevatedButton(
          onPressed: isEditing ? onRemoveImage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
            disabledBackgroundColor:
                isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
            foregroundColor: isEditing
                ? (isDarkMode ? Colors.white : Colors.black)
                : viewOnlyColor,
            disabledForegroundColor: viewOnlyColor,
            elevation: isEditing ? 2 : 0,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Remove Image'),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            // mobile: avatar centered above buttons
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: avatar),
                  const SizedBox(height: 16),
                  buttons,
                  const SizedBox(height: 8),
                  Text(
                    'Support JPEG and PNG formats under 2mb.',
                    style: TextStyle(color: supportTextColor, fontSize: 12),
                  ),
                ],
              )
            // desktop: avatar beside buttons
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(width: 32),
                  Expanded(
                    // ← add this
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buttons,
                        const SizedBox(height: 8),
                        Text(
                          'Support JPEG and PNG formats under 2mb.',
                          style:
                              TextStyle(color: supportTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 16),
        Text(
          'ID NO: $idNumber',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
      ],
    );
  }

  Widget _buildAvatar(bool isMobile) {
    final radius = isMobile ? 50.0 : 70.0;

    if (pickedImageFile != null) {
      return FutureBuilder<ImageProvider>(
        future: _loadPickedImage(),
        builder: (context, snapshot) {
          return CircleAvatar(
            key: ValueKey(pickedImageFile!.name),
            radius: radius,
            backgroundColor:
                isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFDDDDDD),
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
      radius: radius,
      backgroundColor:
          isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFDDDDDD),
      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
          ? NetworkImage(profileImageUrl!)
          : null,
      child: profileImageUrl == null || profileImageUrl!.isEmpty
          ? Icon(
              Icons.person,
              size: isMobile ? 40 : 60,
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
