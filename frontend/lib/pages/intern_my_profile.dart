import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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

  /// Controls whether the form fields are editable.
  /// Starts as false — view-only by default.
  bool _isEditing = false;

  // Snapshot of values at the moment editing begins — used to restore on cancel
  String _snapFirstName = '';
  String _snapLastName = '';
  String _snapProgram = '';
  String _snapSchool = '';
  String _snapPhone = '';
  File? _snapProfileImage;
  String? _snapProfileImageUrl;
  File? _snapResumeFile;

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
        Uri.parse('$_base/intern?id=${widget.userId}'),
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _resumeFile = File(result.files.single.path!));
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final request = http.MultipartRequest(
        'PUT',
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
          // Return to view-only mode after a successful save
          setState(() => _isEditing = false);
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

  /// Cancels editing and restores the pre-edit snapshot — no network call,
  /// no loading flicker.
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _firstNameController.text = _snapFirstName;
      _lastNameController.text = _snapLastName;
      _programController.text = _snapProgram;
      _schoolController.text = _snapSchool;
      _phoneController.text = _snapPhone;
      _profileImage = _snapProfileImage;
      _profileImageUrl = _snapProfileImageUrl;
      _resumeFile = _snapResumeFile;
    });
  }

  void _enterEditing() {
    // Take a snapshot before any edits happen
    _snapFirstName = _firstNameController.text;
    _snapLastName = _lastNameController.text;
    _snapProgram = _programController.text;
    _snapSchool = _schoolController.text;
    _snapPhone = _phoneController.text;
    _snapProfileImage = _profileImage;
    _snapProfileImageUrl = _profileImageUrl;
    _snapResumeFile = _resumeFile;
    setState(() => _isEditing = true);
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
                // ── Title + Edit/Cancel button row ───────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Profile',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    _isEditing
                        ? OutlinedButton.icon(
                            onPressed: _cancelEditing,
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              side: BorderSide(
                                color: widget.isDarkMode
                                    ? Colors.white30
                                    : Colors.black26,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: _enterEditing,
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Profile'),
                            style: FilledButton.styleFrom(
                              backgroundColor: widget.isDarkMode
                                  ? const Color(0xFF4A90D9)
                                  : const Color(0xFF1A73E8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Profile image (editing controls hidden in view mode) ──
                InternProfileImageSection(
                  isDarkMode: widget.isDarkMode,
                  profileImage: _profileImage,
                  profileImageUrl: _profileImageUrl,
                  idNumber: idNumber,
                  onChangeImage: _isEditing ? _pickProfileImage : () {},
                  onRemoveImage: _isEditing ? _removeProfileImage : () {},
                ),
                const SizedBox(height: 24),

                // ── First Name + Last Name ────────────────────────────────
                Row(
                  children: [
                    Expanded(child: _buildLabel('First Name')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLabel('Last Name')),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(controller: _firstNameController),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(controller: _lastNameController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Program'),
                const SizedBox(height: 6),
                _buildField(controller: _programController),
                const SizedBox(height: 16),

                _buildLabel('School'),
                const SizedBox(height: 6),
                _buildField(controller: _schoolController),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildLabel('Email')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLabel('Phone Number')),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Email is always read-only (business rule)
                    Expanded(
                      child: _buildField(
                        controller: _emailController,
                        alwaysReadOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(controller: _phoneController),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Action buttons only visible when editing ──────────────
                if (_isEditing)
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
        color: widget.isDarkMode
            ? const Color(0xFF9E9E9E)
            : const Color(0xFF757575),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    bool alwaysReadOnly = false,
  }) {
    final effectiveReadOnly = alwaysReadOnly || !_isEditing;

    return TextField(
      controller: controller,
      readOnly: effectiveReadOnly,
      style: TextStyle(
        color: (alwaysReadOnly || !_isEditing)
            ? (widget.isDarkMode
                ? const Color(0xFF9E9E9E)
                : const Color(0xFF757575))
            : (widget.isDarkMode ? Colors.white : Colors.black),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.isDarkMode
            ? const Color(0xFF2C2C2C)
            : const Color(0xFFF5F5F5),
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