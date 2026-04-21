import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../widgets/Intern-My-Profile-Widgets/intern_profile_image_section.dart';
import '../widgets/Intern-My-Profile-Widgets/intern_profile_resume_preview.dart';
import '../widgets/Intern-My-Profile-Widgets/intern_profile_action_buttons.dart';

const String _base = 'http://127.0.0.1:8080';

class InternMyProfilePage extends StatefulWidget {
  final bool isDarkMode;
  final String firstName;
  final String userId;

  const InternMyProfilePage({
    super.key,
    required this.isDarkMode,
    required this.firstName,
    required this.userId,
  });

  @override
  State<InternMyProfilePage> createState() => _InternMyProfilePageState();
}

class _InternMyProfilePageState extends State<InternMyProfilePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _programController = TextEditingController();
  final _schoolController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String idNumber = '';
  File? _profileImage;
  File? _resumeFile;
  String? _profileImageUrl;
  String? _resumeUrl;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _programController.dispose();
    _schoolController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('$_base/intern-profile?user_id=${widget.userId}'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _programController.text = data['program'] ?? '';
          _schoolController.text = data['school'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          idNumber = data['id_number'] ?? '';
          _profileImageUrl = data['profile_image_url'];
          _resumeUrl = data['resume_url'];
        });
      }
    } catch (e) {
      debugPrint('fetchProfile error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  void _removeProfileImage() {
    setState(() {
      _profileImage = null;
      _profileImageUrl = null;
    });
  }

  Future<void> _pickResume() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null) {
      setState(() => _resumeFile = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_base/intern-profile/update'),
      );

      request.fields['user_id'] = widget.userId;
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;
      request.fields['program'] = _programController.text;
      request.fields['school'] = _schoolController.text;
      request.fields['phone_number'] = _phoneController.text;

      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImage!.path,
        ));
      }

      if (_resumeFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'resume',
          _resumeFile!.path,
        ));
      }

      final res = await request.send();
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
        _fetchProfile();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile.')),
          );
        }
      }
    } catch (e) {
      debugPrint('saveChanges error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left — full form
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InternProfileImageSection(
                  isDarkMode: widget.isDarkMode,
                  profileImage: _profileImage,
                  profileImageUrl: _profileImageUrl,
                  idNumber: idNumber,
                  onChangeImage: _pickProfileImage,
                  onRemoveImage: _removeProfileImage,
                ),
                const SizedBox(height: 24),
                // First Name + Last Name
                Row(
                  children: [
                    Expanded(
                      child: _buildLabel('First Name'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabel('Last Name'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Program'),
                const SizedBox(height: 6),
                _buildTextField(controller: _programController),
                const SizedBox(height: 16),
                _buildLabel('School'),
                const SizedBox(height: 6),
                _buildTextField(controller: _schoolController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildLabel('Email'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabel('Phone Number'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                InternProfileActionButtons(
                  isDarkMode: widget.isDarkMode,
                  isSaving: _isSaving,
                  onSave: _saveChanges,
                  onUploadResume: _pickResume,
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right — resume preview
          InternProfileResumePreview(
            isDarkMode: widget.isDarkMode,
            resumeFile: _resumeFile,
            resumeUrl: _resumeUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: widget.isDarkMode ? Colors.white : Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(
        color: widget.isDarkMode ? Colors.white : Colors.black,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly
            ? (widget.isDarkMode
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFEEEEEE))
            : (widget.isDarkMode
                ? const Color(0xFF2C2C2C)
                : const Color(0xFFF5F5F5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
