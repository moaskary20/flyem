import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/widgets/api_client_image.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/services/local_notification_service.dart';
import 'package:image_picker/image_picker.dart';

/// شاشة تعديل الملف الشخصي: تغيير الصورة الشخصية.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.currentPhotoUrl,
  });

  final String? currentPhotoUrl;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  XFile? _pickedFile;
  Uint8List? _previewBytes;
  bool _uploading = false;
  String? _error;

  String? get _currentPhotoUrl {
    final url = widget.currentPhotoUrl;
    if (url == null || url.isEmpty) return null;
    return url.replaceAll(RegExp(r'\s'), '').trim();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile != null && mounted) {
      final bytes = await xFile.readAsBytes();
      if (mounted) {
        setState(() {
          _pickedFile = xFile;
          _previewBytes = bytes;
          _error = null;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_pickedFile == null) {
      setState(() => _error = 'اختر صورة أولاً');
      return;
    }
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      final bytes = await _pickedFile!.readAsBytes();
      final photoUrl = await AuthService.uploadProfilePhoto(
        bytes,
        filename: _pickedFile!.name,
        mimeType: _pickedFile!.mimeType,
      );
      if (!mounted) return;
      await LocalNotificationService.showNotification(
        id: LocalNotificationService.idForEvent('profile_saved'),
        title: AppStrings.notificationProfileSaved,
        body: AppStrings.notificationProfileSaved,
      );
      Navigator.of(context).pop(<Object>[photoUrl, bytes]);
    } on AuthException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _uploading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _error = 'فشل رفع الصورة';
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppStrings.editProfileScreenTitle,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _uploading ? null : _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _previewBytes != null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: MemoryImage(_previewBytes!),
                              )
                            : _currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty
                                ? ClipOval(
                                    child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: ApiClientImage(
                                        url: _currentPhotoUrl,
                                        fit: BoxFit.cover,
                                        placeholder: Icon(Icons.person, size: 64, color: Colors.grey[600]),
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey[200],
                                    child: Icon(Icons.person, size: 64, color: Colors.grey[600]),
                                  ),
                        if (!_uploading)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black87,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'اضغط على الصورة لتغييرها',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _uploading ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _uploading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'حفظ الصورة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
