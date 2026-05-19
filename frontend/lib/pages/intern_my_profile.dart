import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/responsive.dart';
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
  final _lastNameController  = TextEditingController();
  final _programController   = TextEditingController();
  final _schoolController    = TextEditingController();
  final _emailController     = TextEditingController();
  final _phoneController     = TextEditingController();

  String? _phoneError;

  String    idNumber           = '';
  XFile?    _pickedImageFile;
  String?   _profileImageUrl;
  PlatformFile? _pickedResumeFile;
  String?   _resumeUrl;
  bool      _isLoading         = false;
  bool      _isSaving          = false;
  bool      _isEditing         = false;
  bool      _removePhotoRequested  = false;
  bool      _removeResumeRequested = false;

  // ── snapshot for cancel ──
  String        _snapFirstName            = '';
  String        _snapLastName             = '';
  String        _snapProgram              = '';
  String        _snapSchool               = '';
  String        _snapPhone                = '';
  XFile?        _snapPickedImageFile;
  String?       _snapProfileImageUrl;
  PlatformFile? _snapPickedResumeFile;
  String?       _snapResumeUrl;
  bool          _snapRemovePhotoRequested  = false;
  bool          _snapRemoveResumeRequested = false;

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

  // ── fetch ────────────────────────────────────────────────────────────────

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse('$_base/intern?id=${widget.userId}'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text  = data['last_name']  ?? '';
          _programController.text   = data['program']    ?? '';
          _schoolController.text    = data['school']     ?? '';
          _emailController.text     = data['email']      ?? '';
          _phoneController.text     = data['phone_number'] ?? '';
          idNumber                  = data['id_number']  ?? '';

          final rawPhoto = data['photo'] ?? '';
          _profileImageUrl = rawPhoto.isNotEmpty
              ? (rawPhoto.startsWith('http') ? rawPhoto : '$_base$rawPhoto')
              : null;

          final rawResume = data['resume'] ?? '';
          _resumeUrl = rawResume.isNotEmpty
              ? (rawResume.startsWith('http') ? rawResume : '$_base$rawResume')
              : null;
        });
      }
    } catch (e) {
      debugPrint('fetchProfile error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── image ────────────────────────────────────────────────────────────────

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _pickedImageFile = picked);
  }

  void _removeProfileImage() {
    setState(() {
      _pickedImageFile     = null;
      _profileImageUrl     = null;
      _removePhotoRequested = true;
    });
  }

  // ── resume ───────────────────────────────────────────────────────────────

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedResumeFile = result.files.first);
    }
  }

  void _removeResume() {
    setState(() {
      _pickedResumeFile        = null;
      _resumeUrl               = null;
      _removeResumeRequested   = true;
    });
  }

  // ── phone validation ─────────────────────────────────────────────────────

  String? _validatePhone(String val) {
    if (val.isEmpty)            return 'Phone number is required';
    if (!val.startsWith('09')) return 'Must start with 09';
    if (val.length != 11)      return 'Must be exactly 11 digits';
    return null;
  }

  // ── save ─────────────────────────────────────────────────────────────────

  Future<void> _saveChanges() async {
    // validate phone before saving
    final phoneErr = _validatePhone(_phoneController.text);
    if (phoneErr != null) {
      setState(() => _phoneError = phoneErr);
      return;
    }
    setState(() => _phoneError = null);

    setState(() => _isSaving = true);
    try {
      final res = await http.put(
        Uri.parse('$_base/update-intern?id=${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name':   _firstNameController.text,
          'last_name':    _lastNameController.text,
          'program':      _programController.text,
          'school':       _schoolController.text,
          'phone_number': _phoneController.text,
        }),
      );

      if (res.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${res.body}')),
          );
        }
        return;
      }

      if (_removePhotoRequested ||
          (_pickedImageFile != null && _profileImageUrl != null)) {
        await http.delete(Uri.parse('$_base/remove-photo?id=${widget.userId}'));
        _removePhotoRequested = false;
      }

      if (_pickedImageFile != null) {
        final bytes    = await _pickedImageFile!.readAsBytes();
        final photoReq = http.MultipartRequest(
          'POST',
          Uri.parse('$_base/upload-photo?id=${widget.userId}'),
        );
        photoReq.files.add(http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: _pickedImageFile!.name,
        ));
        final photoRes = await photoReq.send();
        if (photoRes.statusCode == 200) {
          final body   = await photoRes.stream.bytesToString();
          final json   = jsonDecode(body) as Map<String, dynamic>;
          final newUrl = json['profile_image_url'] as String?;
          if (newUrl != null && mounted) {
            final fullUrl = '$_base$newUrl';
            NetworkImage(fullUrl).evict();
            imageCache.clear();
            imageCache.clearLiveImages();
            setState(() {
              _profileImageUrl = fullUrl;
              _pickedImageFile = null;
            });
          }
        }
      }

      if (_removeResumeRequested ||
          (_pickedResumeFile != null && _resumeUrl != null)) {
        await http.delete(Uri.parse('$_base/remove-resume?id=${widget.userId}'));
        _removeResumeRequested = false;
      }

      if (_pickedResumeFile != null && _pickedResumeFile!.bytes != null) {
        final resumeReq = http.MultipartRequest(
          'POST',
          Uri.parse('$_base/upload-resume?id=${widget.userId}'),
        );
        resumeReq.files.add(http.MultipartFile.fromBytes(
          'resume',
          _pickedResumeFile!.bytes!,
          filename: _pickedResumeFile!.name,
        ));
        final resumeRes = await resumeReq.send();
        if (resumeRes.statusCode == 200) {
          final body   = await resumeRes.stream.bytesToString();
          final json   = jsonDecode(body) as Map<String, dynamic>;
          final newUrl = json['resume_url'] as String?;
          if (newUrl != null && mounted) {
            setState(() {
              _resumeUrl        = '$_base$newUrl';
              _pickedResumeFile = null;
            });
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      debugPrint('saveChanges error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ── edit / cancel ────────────────────────────────────────────────────────

  void _enterEditing() {
    _snapRemovePhotoRequested  = _removePhotoRequested;
    _snapRemoveResumeRequested = _removeResumeRequested;
    _snapFirstName             = _firstNameController.text;
    _snapLastName              = _lastNameController.text;
    _snapProgram               = _programController.text;
    _snapSchool                = _schoolController.text;
    _snapPhone                 = _phoneController.text;
    _snapPickedImageFile       = _pickedImageFile;
    _snapProfileImageUrl       = _profileImageUrl;
    _snapPickedResumeFile      = _pickedResumeFile;
    _snapResumeUrl             = _resumeUrl;
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    setState(() {
      _removePhotoRequested      = _snapRemovePhotoRequested;
      _removeResumeRequested     = _snapRemoveResumeRequested;
      _isEditing                 = false;
      _phoneError                = null;
      _firstNameController.text  = _snapFirstName;
      _lastNameController.text   = _snapLastName;
      _programController.text    = _snapProgram;
      _schoolController.text     = _snapSchool;
      _phoneController.text      = _snapPhone;
      _pickedImageFile           = _snapPickedImageFile;
      _profileImageUrl           = _snapProfileImageUrl;
      _pickedResumeFile          = _snapPickedResumeFile;
      _resumeUrl                 = _snapResumeUrl;
    });
  }

  // ── widgets ──────────────────────────────────────────────────────────────

  Widget _buildEditCancelButton() {
    if (_isEditing) {
      return OutlinedButton.icon(
        onPressed: _cancelEditing,
        icon: const Icon(Icons.close, size: 16),
        label: const Text('Cancel'),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              widget.isDarkMode ? Colors.white70 : Colors.black54,
          side: BorderSide(
            color: widget.isDarkMode ? Colors.white30 : Colors.black26,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: _enterEditing,
      icon: const Icon(Icons.edit, size: 16),
      label: const Text('Edit Profile'),
      style: FilledButton.styleFrom(
        backgroundColor: widget.isDarkMode
            ? const Color(0xFF4A90D9)
            : const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
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
        color: effectiveReadOnly
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

  /// Phone field with 09 prefix enforcement and live error feedback.
  Widget _buildPhoneField() {
    final effectiveReadOnly = !_isEditing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _phoneController,
          readOnly: effectiveReadOnly,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          onChanged: (val) {
            setState(() {
              if (val.isEmpty) {
                _phoneError = null;
              } else if (val.length >= 2 && !val.startsWith('09')) {
                _phoneError = 'Must start with 09';
              } else if (val.length == 11 && val.startsWith('09')) {
                _phoneError = null;
              } else {
                _phoneError = null;
              }
            });
          },
          style: TextStyle(
            color: effectiveReadOnly
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
              borderSide: _phoneError != null
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: _phoneError != null
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: _phoneError != null
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              _phoneError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ── form column ──────────────────────────────────────────────────────────

  Widget _formColumn(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 16),

        // image section + edit button
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InternProfileImageSection(
                    isDarkMode:       widget.isDarkMode,
                    pickedImageFile:  _pickedImageFile,
                    profileImageUrl:  _profileImageUrl,
                    idNumber:         idNumber,
                    isEditing:        _isEditing,
                    onChangeImage:    _pickProfileImage,
                    onRemoveImage:    _removeProfileImage,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildEditCancelButton(),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InternProfileImageSection(
                      isDarkMode:      widget.isDarkMode,
                      pickedImageFile: _pickedImageFile,
                      profileImageUrl: _profileImageUrl,
                      idNumber:        idNumber,
                      isEditing:       _isEditing,
                      onChangeImage:   _pickProfileImage,
                      onRemoveImage:   _removeProfileImage,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildEditCancelButton(),
                ],
              ),

        const SizedBox(height: 16),

        // First + Last name
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('First Name'),
                  const SizedBox(height: 6),
                  _buildField(controller: _firstNameController),
                  const SizedBox(height: 16),
                  _buildLabel('Last Name'),
                  const SizedBox(height: 6),
                  _buildField(controller: _lastNameController),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('First Name'),
                        const SizedBox(height: 6),
                        _buildField(controller: _firstNameController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Last Name'),
                        const SizedBox(height: 6),
                        _buildField(controller: _lastNameController),
                      ],
                    ),
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

        // Email + Phone
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Email'),
                  const SizedBox(height: 6),
                  _buildField(
                      controller: _emailController, alwaysReadOnly: true),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  const SizedBox(height: 6),
                  _buildPhoneField(),
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
                            controller: _emailController,
                            alwaysReadOnly: true),
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
                        _buildPhoneField(),
                      ],
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 32),

        if (_isEditing)
          InternProfileActionButtons(
            isDarkMode:     widget.isDarkMode,
            isSaving:       _isSaving,
            hasResume:      _resumeUrl != null || _pickedResumeFile != null,
            onSave:         _saveChanges,
            onUploadResume: _pickResume,
            onRemoveResume: _removeResume,
          ),
      ],
    );
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isMobile = Responsive.isMobile(context);

    final resumePreview = InternProfileResumePreview(
      isDarkMode:  widget.isDarkMode,
      resumeFile:  _pickedResumeFile,
      resumeUrl:   _resumeUrl,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _formColumn(true),
                const SizedBox(height: 24),
                Center(child: resumePreview),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _formColumn(false)),
                const SizedBox(width: 32),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: resumePreview,
                  ),
                ),
              ],
            ),
    );
  }
}